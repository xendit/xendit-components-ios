//
//  APIResponse.swift
//  XenditComponents
//
//  Created by Ahmad X on 07/04/2026.
//

import Foundation

enum APIResponse {
    struct Empty: Codable {
        init() {}

        static let data: Data = // swiftlint:disable:next force_try
            try! JSONEncoder().encode(Empty())
    }

    static func toAPIClientError(_ error: Error) -> APIClientError {
        // -999 = URLError cancelled
        if let error = error as? APIClientError {
            return error
        } else if let error = error as? URLError {
            if error.code == .cancelled {
                return .init(.cancelled, nativeError: error)
            } else if error.code == .notConnectedToInternet {
                return .init(.noInternet, nativeError: error)
            }
        }
        return .init(nativeError: error)
    }
}

// MARK: - ErrorObject

extension APIResponse {
    struct ErrorObject {
        let errorCode: String
        let message: String
        let errorContent: APIClientError.BackendError.ErrorContent?
        let meta: [String: String]?
    }
}

extension APIResponse.ErrorObject: Decodable {
    private enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case message
        case errorContent = "error_content"
        case meta
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        errorCode = try values.decode(String.self, forKey: .errorCode)
        message = try values.decode(String.self, forKey: .message)
        errorContent = try? values.decodeIfPresent(APIClientError.BackendError.ErrorContent.self, forKey: .errorContent)
        meta = try? values.decodeIfPresent([String: String].self, forKey: .meta)
    }
}

extension APIResponse.ErrorObject {
    func toAPIClientError(_ httpStatusCode: Int) -> APIClientError {
        func create(_ type: APIClientError.ErrorType) -> APIClientError {
            .init(
                type,
                backendError: .init(code: errorCode, message: message, errorContent: errorContent, meta: meta),
                httpStatusCode: httpStatusCode
            )
        }
       
        return create(ErrorCode(rawValue: errorCode)?.type ?? .unknown)
    }
}

private extension ErrorCode {
    var type: APIClientError.ErrorType? {
        switch self {
        case .VALIDATION_ERROR:
            return .validationError
        default:
            break
        }
        
        return nil
    }
}
