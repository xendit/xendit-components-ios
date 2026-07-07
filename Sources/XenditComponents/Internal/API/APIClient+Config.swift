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
        let appVersion: String?
        let bundleId: String
        let bundleHostId: String?
        let defaultTimeout: TimeInterval // Must be shorter than maxTimeout
        let maxTimeout: TimeInterval

        init(
            apiVersion: String = "",
            appVersion: String? = "",
            bundleId: String = "",
            bundleHostId: String? = nil,
            defaultTimeout: TimeInterval = 60,
            maxTimeout: TimeInterval = 60,
        ) {
            self.apiVersion = apiVersion
            self.appVersion = appVersion
            self.bundleId = bundleId
            self.bundleHostId = bundleHostId
            self.defaultTimeout = defaultTimeout
            self.maxTimeout = maxTimeout
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
