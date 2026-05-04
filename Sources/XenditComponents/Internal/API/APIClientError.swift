//
//  APIClientError.swift
//  XenditComponents
//
//  Created by Ahmad X on 07/04/2026.
//

import Foundation

struct APIClientError: Error {
    let type: ErrorType
    let backendError: BackendError?
    let nativeError: Error?
    let httpStatusCode: Int?

    init(
        _ type: ErrorType = .unknown,
        backendError: BackendError? = nil,
        nativeError: Error? = nil,
        httpStatusCode: Int? = nil
    ) {
        self.type = type
        self.backendError = backendError
        self.nativeError = nativeError
        self.httpStatusCode = httpStatusCode
    }
}

extension APIClientError: Equatable {
    static func == (lhs: APIClientError, rhs: APIClientError) -> Bool {
        lhs.type == rhs.type
            && lhs.backendError == rhs.backendError
            && lhs.httpStatusCode == rhs.httpStatusCode
    }
}

extension APIClientError: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(backendError)
        hasher.combine(httpStatusCode)
    }
}

// MARK: - BackendError

extension APIClientError {
    struct BackendError: Hashable {
        let code: String
        let message: String
        let errorContent: ErrorContent?
        let meta: [String: String]?

        struct ErrorContent: Hashable, Decodable {
            let title: String
            let message1: String
            let message2: String?

            private enum CodingKeys: String, CodingKey {
                case title
                case message1 = "message_1"
                case message2 = "message_2"
            }
        }
    }
}

// MARK: - ErrorType

extension APIClientError {
    enum ErrorType: Hashable {
        
        //TODO: Still placeholder will be rmove
        //MARK: - PLACEHOLDER
        case validationError
        
        // MARK: - Non-mapped errors

        case noHttpResponse
        case noInternet
        case invalidInput
        case cancelled

        // MARK: - Misc

        case unknown // Unknown error (likely something new from BE)

    }
}
