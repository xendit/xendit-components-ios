//
//  XenditStrings.swift
//  XenditComponents
//
//  Created by Ahmad X on 04/05/2026.
//

import Foundation

// MARK: - Localization

struct XenditStrings {
    private let locale: String

    init(locale: String) {
        self.locale = locale
    }

    func string(for key: LocalizationKey, replacements: [String: String] = [:]) -> String {
        return localize(key.rawValue, replacements: replacements)
    }

    /// Returns the localized validation message for a given validation code, or `nil` when no
    /// matching key exists in the strings file (e.g. a server-supplied regex error message).
    func validationMessage(forCode code: String, fieldLabel: String) -> String? {
        return localizeOptional("session::validation.\(code)", replacements: ["field": fieldLabel])
    }

    /// Returns the localized failure message for a given failure code raw value, or `nil` when
    /// the code has no entry in the strings file.
    func failureMessage(forCode code: String) -> String? {
        return localizeOptional("session::failure_code.\(code.lowercased())")
    }

    // MARK: - Private

    private func localize(_ key: String, replacements: [String: String] = [:]) -> String {
        let bundle = Self.lprojBundle(for: locale)
        let value = bundle.localizedString(forKey: key, value: key, table: "Localizable")
        return applying(replacements: replacements, to: value)
    }

    private func localizeOptional(_ key: String, replacements: [String: String] = [:]) -> String? {
        let sentinel = "__XENDIT_NOT_FOUND__"
        let bundle = Self.lprojBundle(for: locale)
        let result = bundle.localizedString(forKey: key, value: sentinel, table: "Localizable")
        guard result != sentinel else { return nil }
        return applying(replacements: replacements, to: result)
    }

    private func applying(replacements: [String: String], to string: String) -> String {
        var result = string
        for (placeholder, value) in replacements {
            result = result.replacingOccurrences(of: "{{\(placeholder)}}", with: value)
        }
        return result
    }

    private static func lprojBundle(for locale: String) -> Bundle {
        let base = locale.split(separator: "-").first.map(String.init) ?? locale
        if let path = Bundle.module.path(forResource: base, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        if let path = Bundle.module.path(forResource: "en", ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return Bundle.module
    }
}
