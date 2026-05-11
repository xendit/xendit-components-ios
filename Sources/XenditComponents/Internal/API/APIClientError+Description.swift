//
//  APIClientError+Description.swift
//  XenditComponents
//
//  Created by Ahmad X on 27/04/2026.
//

import Foundation

extension APIClientError: LocalizedError {
    var errorDescription: String? {
        optionalDescription ?? "Something Went Wrong" //TODO: Localize
    }

    // This function will return nil if no mapped error found
    var optionalDescription: String? {
        if let description = backendError?.description {
            return description
        }

        switch type {
        case .noInternet:
            return "No Internet Connection"

        // MARK: - Only used in log for now, no need to localize

        case .noHttpResponse:
            return "No HTTP response"
        default:
            break
        }

        if let error = nativeError {
            if let decodingError = nativeError as? DecodingError {
                    return getDecodingError(decodingError)
                }
                
                return error.localizedDescription
        }
        return nil
    }
}

// MARK: - Convenience

private extension APIClientError {
    func getDecodingError(_ error: Error) -> String {
        guard let decodingError = error as? DecodingError else {
            return error.localizedDescription
        }

        switch decodingError {
        case .keyNotFound(let key, let context):
            let path = context.codingPath.map { $0.stringValue }.joined(separator: ".")
            let fullPath = path.isEmpty ? key.stringValue : "\(path).\(key.stringValue)"
            return "Missing Field: The key '\(fullPath)' is required but was not found."

        case .typeMismatch(let type, let context):
            let path = context.codingPath.map { $0.stringValue }.joined(separator: ".")
            return "Type Mismatch: Expected \(type) at '\(path)', but found a different type."

        case .valueNotFound(let type, let context):
            let path = context.codingPath.map { $0.stringValue }.joined(separator: ".")
            return "Value Missing: Expected \(type) at '\(path)', but found a null or empty value."

        case .dataCorrupted(let context):
            return "Data Corrupted: The JSON is malformed. Error: \(context.debugDescription)"

        @unknown default:
            return "Unknown decoding error occurred."
        }
    }
}

// MARK: - BackendError

private extension APIClientError.BackendError {
    var description: String? {
        let combined = "\(errorContent?.message1 ?? "")  \(errorContent?.message2 ?? "")".trimmingCharacters(in: .whitespaces)
        return combined.isEmpty ? message : combined
    }
}
