//
//  FieldPropertyMapper.swift
//  XenditComponents
//
//  Created by Ahmad X on 05/06/2026.
//

import Foundation

protocol FieldPropertyMapper {
    func getValue(from properties: ChannelProperties, keys: [String], initialValue: String?) -> String
    func setValue(_ value: String, into properties: inout ChannelProperties, keys: [String])
}

struct DefaultFieldMapper: FieldPropertyMapper {
    func getValue(from properties: ChannelProperties, keys: [String], initialValue: String?) -> String {
        guard let key = keys.first else { return initialValue ?? "" }
        return properties[key] ?? initialValue ?? ""
    }
    func setValue(_ value: String, into properties: inout ChannelProperties, keys: [String]) {
        guard let key = keys.first else { return }
        properties[key] = value
    }
}

/// Maps a single encoded string "terms|interval|code" to/from three installment keys.
/// keys[0] = installment_configuration.terms
/// keys[1] = installment_configuration.interval
/// keys[2] = installment_configuration.code
struct InstallmentPlanFieldMapper: FieldPropertyMapper {
    func getValue(from properties: ChannelProperties, keys: [String], initialValue: String?) -> String {
        guard keys.count >= 3 else { return initialValue ?? "" }
        let terms    = properties[keys[0]] ?? ""
        let interval = properties[keys[1]] ?? ""
        let code     = properties[keys[2]] ?? ""
        // No terms key means Pay in Full is active — return its encoded value so the picker
        // can match and highlight it correctly.
        guard !terms.isEmpty, terms != "0" else { return "0||" }
        return "\(terms)|\(interval)|\(code)"
    }

    func setValue(_ value: String, into properties: inout ChannelProperties, keys: [String]) {
        guard keys.count >= 3 else { return }
        // Split into at most 3 parts so a "|" inside code (unlikely) is preserved.
        let parts = value.split(separator: "|", maxSplits: 2, omittingEmptySubsequences: false).map(String.init)
        let terms = parts.count > 0 ? parts[0] : ""
        guard !terms.isEmpty, terms != "0" else {
            // Pay in Full (terms == 0) — remove any previously written installment keys.
            keys.prefix(3).forEach { properties[$0] = nil }
            return
        }
        // Store as a clean integer string; XenditMapper converts to Int when building the API payload.
        properties[keys[0]] = Int(terms).map { String($0) } ?? terms
        properties[keys[1]] = parts.count > 1 ? parts[1] : ""
        let code = parts.count > 2 ? parts[2] : ""
        if !code.isEmpty {
            properties[keys[2]] = code
        }
    }
}

/// Maps a single MM/YY string to/from separate expiry_month and expiry_year keys.
/// keys[0] = expiry_month, keys[1] = expiry_year
struct CreditCardExpiryMapper: FieldPropertyMapper {
    func getValue(from properties: ChannelProperties, keys: [String], initialValue: String?) -> String {
        guard keys.count >= 2 else { return DefaultFieldMapper().getValue(from: properties, keys: keys, initialValue: initialValue) }
        let month = properties[keys[0]] ?? ""
        let year  = properties[keys[1]] ?? ""
        guard !month.isEmpty || !year.isEmpty else { return initialValue ?? "" }
        return "\(month)/\(year)"
    }

    func setValue(_ value: String, into properties: inout ChannelProperties, keys: [String]) {
        guard keys.count >= 2 else { return }
        let parts = value.split(separator: "/", maxSplits: 1).map(String.init)
        properties[keys[0]] = parts.count > 0 ? parts[0] : ""
        properties[keys[1]] = parts.count > 1 ? parts[1] : ""
    }
}
