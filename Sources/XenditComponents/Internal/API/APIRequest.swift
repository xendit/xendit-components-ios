//
//  APIRequest.swift
//  XenditComponents
//
//  Created by Ahmad X on 07/04/2026.
//

import Foundation

struct APIRequest {
    let method: Method
    let endPoint: EndPoint
    let extraHeaders: [Header]
    let parameter: Parameter

    init(method: Method = .get, endPoint: EndPoint, extraHeaders: [Header] = [], parameter: Parameter = .none) {
        self.method = method
        self.endPoint = endPoint
        self.extraHeaders = extraHeaders
        self.parameter = parameter
    }

    func getURLRequest(
        config: APIClient.Config,
        settings: APIClient.Settings,
        token: String? = nil,
        options: APIClient.Options = .init()
    ) -> URLRequest {
        // Build URL
        var requestUrl = endPoint.getUrl(config: config, settings: settings)
        if case let .query(items) = parameter {
            var urlComponents = URLComponents(string: requestUrl.absoluteString)!
            let queryItems = items.compactMap {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
            urlComponents.queryItems = queryItems
            if let urlWithQueries = urlComponents.url {
                requestUrl = urlWithQueries
            } else {
                fatalError("Cannot convert query parameters: \(items)")
            }
        }

        // Create request
        var request = URLRequest(url: requestUrl)
        request.httpMethod = method.rawValue
        request.timeoutInterval = options.timeout ?? config.defaultTimeout

        // Set compulsory headers
        if let appVersion = config.appVersion {
            let version = appVersion.hasPrefix("v") ? String(appVersion.dropFirst()) : appVersion
            request.addValue("ios:\(version)", forHTTPHeaderField: "x-sdk-version")
        }
        if let hostId = config.bundleHostId {
            request.addValue(hostId, forHTTPHeaderField: "x-host-id")
        }


        for header in extraHeaders {
            switch header {
            case let .custom(key, value):
                request.addValue(value, forHTTPHeaderField: key)
            default:
                break
            }
        }
        if let token = token {
            request.addAuthorization(token)
        }


        // Set body
        switch parameter {
        case .none, .query:
            request.setJSONContent()

        case let .jsonObjects(dictionary):
            request.setJSONContent(dictionary.jsonData)

        case let .multipart(objects):
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = objects.getHttpData(with: boundary)

        case let .imageData(type, data):
            request.setValue("image/\(type.rawValue)", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
        }
        return request
    }
}

// MARK: - Enums and structs

extension APIRequest {
    enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    enum EndPoint {
        case path(String)
        case v(Int, String)
        case url(URL)
        case urlString(String)

        func getUrl(config: APIClient.Config, settings: APIClient.Settings) -> URL {
            let version: String = {
                switch self {
                case let .v(version, _):
                    return "/v\(version)"
                default:
                    break
                }
                return config.apiVersion
            }()

            switch self {
            case let .path(path), let .v(_, path):
                var urlString = settings.apiUrl + version + path
                guard let url = URL(string: urlString) else {
                    fatalError("Something wrong with URL: \(path)")
                }
                return url
            case let .url(url):
                return url
            case let .urlString(urlString):
                guard let url = URL(string: urlString) else {
                    fatalError("Something wrong with URL: \(urlString)")
                }
                return url
            }
        }
    }

    enum Header: Hashable {
        case custom(String, String)
    }

    enum Parameter {
        case none
        case query([String: Any])
        case jsonObjects([String: Any])
        case multipart([MultipartObject])
        case imageData(ImageType, Data)
    }

    enum ImageType: String {
        case jpeg
        case png
        case tiff
    }

    struct MultipartObject {
        let data: Data
        let contentType: ContentType
        let name: String
        let fileName: String

        init(
            data: Data,
            contentType: ContentType,
            name: String,
            fileName: String
        ) {
            self.data = data
            self.contentType = contentType
            self.name = name
            self.fileName = fileName
        }
    }

    enum ContentType: String {
        case imageJpeg = "image/jpeg"
        case imagePng = "image/png"
        case applicationJson = "application/json"
        case applicationPdf = "application/pdf"
    }
}

extension Dictionary where Key == String, Value == Any {
    var jsonData: Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: [])
        } catch {
            Logger.warning("Failed to convert to JSON, error: \(error.localizedDescription)")
        }
        return nil
    }
}

extension [APIRequest.MultipartObject] {
    func getHttpData(with boundary: String) -> Data {
        var data = Data()
        for object in self {
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(object.name)\"; filename=\"\(object.fileName)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: \(object.contentType.rawValue)\r\n\r\n".data(using: .utf8)!)
            data.append(object.data)
        }
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        return data
    }
}

// MARK: - Extensions

extension URLRequest {
    mutating func addAuthorization(_ authorization: String) {
        addValue(authorization, forHTTPHeaderField: "Authorization")
    }

    mutating func setJSONContent(_ data: Data? = nil) {
        addValue(APIRequest.ContentType.applicationJson.rawValue, forHTTPHeaderField: "Content-Type")
        addValue(APIRequest.ContentType.applicationJson.rawValue, forHTTPHeaderField: "Accept")
        if let data = data {
            httpBody = data
        }
    }
}
