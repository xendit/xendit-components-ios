//
//  APIClient.swift
//  XenditComponents
//
//  Created by Ahmad X on 07/04/2026.
//

import Combine
import Foundation
import Network

final class APIClient {
    static private(set) var shared = APIClient(config: .init(), settings: .init())
    
    let settings: Settings
    
    private(set) var hasInternet = true
        
    // For decoding date time string from backend
    static let dateTimeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter(calendar: .gregorian)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }()
    
    // For decoding date only string from backend
    static let dateOnlyFormatter: DateFormatter = {
        let dateFormatter = DateFormatter(calendar: .gregorian)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    static let hashDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter(calendar: .gregorian)
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        return dateFormatter
    }()
    
    static func setup(config: Config, settings: Settings) {
        shared = APIClient(config: config, settings: settings)
    }
    
    func performArray<T: Decodable>(_ request: APIRequest, options: APIClient.Options = .init()) -> AnyPublisher<[T], APIClientError> {
        perform(request, options: options)
            .map { (array: [OptionalObject<T>]) in
                array.compactMap { $0.value }
            }
            .mapError(APIResponse.toAPIClientError)
            .eraseToAnyPublisher()
    }
    
    // NOTE: Session's timeout must be longer than defaultTimeout, else session timeout will always be used
    func perform<T: Decodable>(_ request: APIRequest, options: APIClient.Options = .init()) -> AnyPublisher<T, APIClientError> {
        return perform(request, token: nil, options: options)
    }
    
    
    // MARK: - Private
    
    private let config: Config
    private let urlCache: URLCache
    private let normalSession: URLSession
    private let noCacheSession: URLSession //Rename this as normal Session
    private let queue = DispatchQueue(label: "APIClient", qos: .userInitiated, attributes: .concurrent)
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(APIClient.dateTimeFormatter)
        return decoder
    }
    
    private let networkMonitor = NWPathMonitor()
    private let networkMonitorQueue = DispatchQueue(label: "APIClient.networkMonitor")
    private var subscriptions = Set<AnyCancellable>()
    
    private init(config: Config, settings: Settings) {
        self.config = config
        self.settings = settings
        
        func createSessionConfig() -> URLSessionConfiguration {
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = config.maxTimeout
            sessionConfig.timeoutIntervalForResource = config.maxTimeout
            return sessionConfig
        }
        
        let urlCache = URLCache()
        self.urlCache = urlCache
        
        var sessionConfig = createSessionConfig()
        sessionConfig.urlCache = urlCache
        normalSession = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        sessionConfig = createSessionConfig()
        sessionConfig.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        sessionConfig.urlCache = nil
        noCacheSession = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        monitorNetwork()
    }

    deinit {
        networkMonitor.cancel()
    }
    
    private func monitorNetwork() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.hasInternet = path.status == .satisfied
            }
        }
        networkMonitor.start(queue: networkMonitorQueue)
    }
    
    private func perform<T: Decodable>(_ request: APIRequest, token: String?, options: APIClient.Options = .init()) -> AnyPublisher<T, APIClientError> {
        func publisherForError(_ type: APIClientError.ErrorType) -> AnyPublisher<T, APIClientError> {
            Result.failure(.init(type)).publisher.receive(on: DispatchQueue.main).eraseToAnyPublisher()
        }
        
        guard hasInternet else {
            return publisherForError(.noInternet)
        }
        
        guard var urlRequest = request.getURLRequest(config: config, settings: settings, token: token, options: options) else {
            return publisherForError(.invalidInput)
        }
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        guard let urlString = urlRequest.url?.absoluteString else {
            return publisherForError(.invalidInput)
        }
        
        let session: URLSession = noCacheSession
        
        let publisher: AnyPublisher<T, APIClientError> = responsePublisher(
            using: session
                .dataTaskPublisher(for: urlRequest)
                .map { ($0, $1) }
                .mapError { $0 as Error }
                .eraseToAnyPublisher(),
            options: options,
            urlString: urlString
        )
        
        return publisher
    }
    
    private func responsePublisher<T: Decodable>(
        using publisher: AnyPublisher<(Data, URLResponse), Error>,
        options: APIClient.Options,
        urlString: String
    ) -> AnyPublisher<T, APIClientError> {
        publisher
            .subscribe(on: queue)
            .tryMap { [weak self] data, response in
                guard let self else { return data }
                let config = self.config
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIClientError(.noHttpResponse)
                }
                switch httpResponse.statusCode {
                case 200 ... 399:
                    let responseData = data.isEmpty ? APIResponse.Empty.data : data
                    
                    return responseData
                default:
                    var requestError: APIClientError = .init(httpStatusCode: httpResponse.statusCode)
                    do {
                        let error = try JSONDecoder().decode(APIResponse.ErrorObject.self, from: data).toAPIClientError(httpResponse.statusCode)
                        requestError = error
                    } catch {
                    }
                    throw requestError
                }
            }
            .decode(type: T.self, decoder: decoder)
            .mapError(APIResponse.toAPIClientError)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Options
extension APIClient {
    struct Options {
        let timeout: TimeInterval?
        
        init(
            timeout: TimeInterval? = nil,
        ) {
            self.timeout = timeout
        }
    }
}

// MARK: - Convenience

// swiftlint:disable line_length
extension APIClient {
    func get<T: Decodable>(_ endPoint: APIRequest.EndPoint, parameter: APIRequest.Parameter = .none, headers: [APIRequest.Header] = [], options: APIClient.Options = .init()) -> AnyPublisher<T, APIClientError> {
        perform(APIRequest(method: .get, endPoint: endPoint, extraHeaders: headers, parameter: parameter), options: options)
    }

    func get<T: Decodable>(_ endPoint: APIRequest.EndPoint, queries: [String: Any], headers: [APIRequest.Header] = [], options: APIClient.Options = .init()) -> AnyPublisher<T, APIClientError> {
        perform(APIRequest(method: .get, endPoint: endPoint, extraHeaders: headers, parameter: .query(queries)), options: options)
    }

    func post<T: Decodable>(_ endPoint: APIRequest.EndPoint, parameter: APIRequest.Parameter = .none, headers: [APIRequest.Header] = [], options: APIClient.Options = .init()) -> AnyPublisher<T, APIClientError> {
        perform(APIRequest(method: .post, endPoint: endPoint, extraHeaders: headers, parameter: parameter), options: options)
    }

    func post<T: Decodable>(_ endPoint: APIRequest.EndPoint, json: [String: Any], headers: [APIRequest.Header] = [], options: APIClient.Options = .init()) -> AnyPublisher<T, APIClientError> {
        perform(APIRequest(method: .post, endPoint: endPoint, extraHeaders: headers, parameter: .jsonObjects(json)), options: options)
    }

    func upload<T: Decodable>(_ endPoint: APIRequest.EndPoint, objects: [APIRequest.MultipartObject], headers: [APIRequest.Header] = [], options: APIClient.Options = .init(timeout: 120)) -> AnyPublisher<T, APIClientError> {
        perform(APIRequest(method: .post, endPoint: endPoint, extraHeaders: headers, parameter: .multipart(objects)), options: options)
    }

    func put<T: Decodable>(_ endPoint: APIRequest.EndPoint, parameter: APIRequest.Parameter = .none, headers: [APIRequest.Header] = [], options: APIClient.Options = .init()) -> AnyPublisher<T, APIClientError> {
        perform(APIRequest(method: .put, endPoint: endPoint, extraHeaders: headers, parameter: parameter), options: options)
    }

    func put<T: Decodable>(_ endPoint: APIRequest.EndPoint, json: [String: Any], headers: [APIRequest.Header] = [], options: APIClient.Options = .init()) -> AnyPublisher<T, APIClientError> {
        perform(APIRequest(method: .put, endPoint: endPoint, extraHeaders: headers, parameter: .jsonObjects(json)), options: options)
    }

    func patch<T: Decodable>(_ endPoint: APIRequest.EndPoint, parameter: APIRequest.Parameter = .none, headers: [APIRequest.Header] = [], options: APIClient.Options = .init()) -> AnyPublisher<T, APIClientError> {
        perform(APIRequest(method: .patch, endPoint: endPoint, extraHeaders: headers, parameter: parameter), options: options)
    }

    func patch<T: Decodable>(_ endPoint: APIRequest.EndPoint, json: [String: Any], headers: [APIRequest.Header] = [], options: APIClient.Options = .init()) -> AnyPublisher<T, APIClientError> {
        perform(APIRequest(method: .patch, endPoint: endPoint, extraHeaders: headers, parameter: .jsonObjects(json)), options: options)
    }

    func delete<T: Decodable>(_ endPoint: APIRequest.EndPoint, headers: [APIRequest.Header] = [], options: APIClient.Options = .init()) -> AnyPublisher<T, APIClientError> {
        perform(APIRequest(method: .delete, endPoint: endPoint, extraHeaders: headers), options: options)
    }

    // Below methods are to be used when responce is an array of objects.
    // This will keep all the elements that contains all declared fields in needed format.
    // It'll ignore other elements where some parameters are absent or in a different format.
    func getArray<T: Decodable>(_ endPoint: APIRequest.EndPoint, parameter: APIRequest.Parameter = .none, headers: [APIRequest.Header] = [], options: APIClient.Options = .init()) -> AnyPublisher<[T], APIClientError> {
        performArray(APIRequest(method: .get, endPoint: endPoint, extraHeaders: headers, parameter: parameter), options: options)
    }

    func getArray<T: Decodable>(_ endPoint: APIRequest.EndPoint, queries: [String: Any], headers: [APIRequest.Header] = [], options: APIClient.Options = .init()) -> AnyPublisher<[T], APIClientError> {
        performArray(APIRequest(method: .get, endPoint: endPoint, extraHeaders: headers, parameter: .query(queries)), options: options)
    }

    func postArray<T: Decodable>(_ endPoint: APIRequest.EndPoint, parameter: APIRequest.Parameter = .none, headers: [APIRequest.Header] = [], options: APIClient.Options = .init()) -> AnyPublisher<[T], APIClientError> {
        performArray(APIRequest(method: .post, endPoint: endPoint, extraHeaders: headers, parameter: parameter), options: options)
    }

    func postArray<T: Decodable>(_ endPoint: APIRequest.EndPoint, json: [String: Any], headers: [APIRequest.Header] = [], options: APIClient.Options = .init()) -> AnyPublisher<[T], APIClientError> {
        performArray(APIRequest(method: .post, endPoint: endPoint, extraHeaders: headers, parameter: .jsonObjects(json)), options: options)
    }
}
