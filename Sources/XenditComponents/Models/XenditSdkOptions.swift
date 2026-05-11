//
//  XenditSdkOptions.swift
//  XenditComponents
//
//  Created by Ahmad X on 28/04/2026.
//

import Foundation

/// Configuration options for the Xendit Components SDK.
public struct XenditSdkOptions {
    /// The client key from your session.
    /// Your server should retrieve this from the Xendit API and pass it directly
    /// to the client without saving or logging it.
    public let componentsSdkKey: String

    public init(componentsSdkKey: String) {
        self.componentsSdkKey = componentsSdkKey
    }
}

// MARK: - Parsed SDK Key

struct ParsedSdkKey {
    let sessionAuthKey: String
    let hostId: String
    let publicKey: String
    let signature: String

    static let knownHosts: [String: String] = [
        "pl": "https://checkout-ui-gateway.xendit.co",
        "pd": "https://checkout-ui-gateway-prod-dev.xendit.co",
        "sl": "https://checkout-ui-gateway-live.stg.tidnex.dev",
        "sd": "https://checkout-ui-gateway-dev.stg.tidnex.dev"
    ]

    static func parse(_ componentsSdkKey: String) throws -> ParsedSdkKey {
        guard !componentsSdkKey.isEmpty else {
            throw XenditAPIError.invalidSDKKey("The componentsSdkKey option is missing.")
        }

        let parts = componentsSdkKey.split(separator: "-", omittingEmptySubsequences: false).map(String.init)
        guard parts.count >= 4 else {
            throw XenditAPIError.invalidSDKKey(
                "The componentsSdkKey has the wrong format. Ensure you pass the value returned from the components_sdk_key property of the POST /sessions response."
            )
        }

        let sessionAuthKey = [parts[0], parts[1]].joined(separator: "-")
        let hostId = parts[2]
        let publicKey = parts[3]
        let signature = parts.count > 4 ? parts[4] : ""

        guard knownHosts[hostId] != nil else {
            throw XenditAPIError.invalidSDKKey(
                "Unknown hostId '\(hostId)' in componentsSdkKey."
            )
        }

        return ParsedSdkKey(
            sessionAuthKey: sessionAuthKey,
            hostId: hostId,
            publicKey: publicKey,
            signature: signature
        )
    }

    var baseURL: URL {
        URL(string: Self.knownHosts[hostId]!)!
    }
}


