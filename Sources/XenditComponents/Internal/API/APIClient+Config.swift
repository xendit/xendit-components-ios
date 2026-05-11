//
//  APIClient+Config.swift
//  XenditComponents
//
//  Created by Ahmad X on 07/04/2026.
//

import Foundation

extension APIClient {
    struct Config {
        let apiVersion: String
        let deviceIdKey: String
        let appVersion: String?
        let bundleId: String
        let bundleHostId: String?
        let defaultTimeout: TimeInterval // Must be shorter than maxTimeout
        let maxTimeout: TimeInterval
        let enableSSLPinning: Bool
        let sslPinningCertificate: String?
        let sslPinningPublicKeyHashes: [String]
        let logoutNotification: Notification.Name
        let forceUpdateNotification: Notification.Name

        init(
            apiVersion: String = "",
            deviceIdKey: String = "",
            appVersion: String? = "",
            bundleId: String = "",
            bundleHostId: String? = nil,
            defaultTimeout: TimeInterval = 60,
            maxTimeout: TimeInterval = 60,
            enableSSLPinning: Bool = true,
            sslPinningCertificate: String? = nil,
            sslPinningPublicKeyHashes: [String] = [],
            logoutNotification: Notification.Name = .init(rawValue: ""),
            forceUpdateNotification: Notification.Name = .init(rawValue: "")
        ) {
            self.apiVersion = apiVersion
            self.deviceIdKey = deviceIdKey
            self.appVersion = appVersion
            self.bundleId = bundleId
            self.bundleHostId = bundleHostId
            self.defaultTimeout = defaultTimeout
            self.maxTimeout = maxTimeout
            self.enableSSLPinning = enableSSLPinning
            self.sslPinningCertificate = sslPinningCertificate
            self.sslPinningPublicKeyHashes = sslPinningPublicKeyHashes
            self.logoutNotification = logoutNotification
            self.forceUpdateNotification = forceUpdateNotification
        }
    }
}

extension APIClient {
    class Settings {
        @Atomic(default: "")
        var apiUrl: String

        @Atomic(default: "")
        var language: String

        init() {}
    }
}
