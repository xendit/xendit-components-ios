//
//  XenditAPIError.swift
//  XenditComponents
//
//  Created by Ahmad X on 28/04/2026.
//

import Foundation

enum XenditAPIError: Error, LocalizedError {
    case invalidSDKKey(String)
    case networkError(Error)
    case serverError(code: String, message: String, content: ErrorContent?)
    case decodingError(Error)
    case invalidURL
    case unknown

    struct ErrorContent {
        let title: String
        let message1: String
        let message2: String?

        init(title: String, message1: String, message2: String?) {
            self.title = title
            self.message1 = message1
            self.message2 = message2
        }

        init(_ backendContent: APIClientError.BackendError.ErrorContent) {
            self.title = backendContent.title
            self.message1 = backendContent.message1
            self.message2 = backendContent.message2
        }
    }

    var errorDescription: String? {
        switch self {
        case .invalidSDKKey(let msg):
            return "Invalid SDK key: \(msg)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let code, let message, _):
            return "Server error [\(code)]: \(message)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid URL"
        case .unknown:
            return "An unknown error occurred"
        }
    }

    var userErrorMessages: [String]? {
        switch self {
        case .serverError(_, _, let content):
            guard let content else { return nil }
            return [content.title, content.message1, content.message2].compactMap { $0 }
        default:
            return nil
        }
    }
}
