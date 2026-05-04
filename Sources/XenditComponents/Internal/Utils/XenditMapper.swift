//
//  XenditMapper.swift
//  XenditComponents
//
//  Created by Ahmad X on 28/04/2026.
//

import Foundation

// MARK: - Mapper

struct XenditMapper {

    static func mapFormValues(
        formValues: [String: String],
        fields: [SessionResponse.Channel.FormField],
        publicKey: String,
        sessionId: String
    ) -> [String: Any] {
        var flatMap = [String: Any?]()

        for field in fields {
            let propertyKey = field.channelProperty.primaryKey
            let isSensitive = isSensitiveField(field)
            let keys = field.channelProperty.keys

            if case .creditCardExpiry = field.type {
                // CreditCardExpiryMapper already stored month and year in their individual
                // keys, so read them directly rather than re-parsing a combined string.
                guard keys.count >= 2 else { continue }
                let month = formValues[keys[0]] ?? ""
                let rawYear = formValues[keys[1]] ?? ""
                let year = rawYear.count == 2 ? "20\(rawYear)" : rawYear

                flatMap[keys[0]] = isSensitive
                    ? (try? XenditEncryption.encrypt(data: month, serverPublicKeyBase64: publicKey, sessionId: sessionId)) ?? month
                    : month
                flatMap[keys[1]] = isSensitive
                    ? (try? XenditEncryption.encrypt(data: year, serverPublicKeyBase64: publicKey, sessionId: sessionId)) ?? year
                    : year
                continue
            }

            guard let value = formValues[propertyKey] else { continue }

            switch field.type {
            case .text(_, _, _, _), .email, .postalCode, .creditCardNumber, .creditCardCvn:
                let key = keys.first ?? ""
                let encryptedValue = isSensitive
                    ? try? XenditEncryption.encrypt(data: value, serverPublicKeyBase64: publicKey, sessionId: sessionId)
                    : value
                flatMap[key] = encryptedValue ?? value
            case .installmentPlan:
                guard keys.count >= 2 else { continue }
                let term = formValues[keys[0]]
                let interval = formValues[keys[1]]
                let code = formValues[keys[2]]

                flatMap[keys[0]] = term
                flatMap[keys[1]] = interval
                flatMap[keys[2]] = code
            default:
                let key = keys.first ?? ""
                flatMap[key] = value
            }
        }

        return unflatten(flatMap.compactMapValues { $0 })
    }

    private static func isSensitiveField(_ field: SessionResponse.Channel.FormField) -> Bool {
        return ["credit_card_number", "credit_card_expiry", "credit_card_cvn"].contains(field.type.name)
    }

    private static func unflatten(_ flatMap: [String: Any]) -> [String: Any] {
        var result = [String: Any]()
        for (key, value) in flatMap {
            let parts = key.components(separatedBy: ".")

            // This is a simplified unflattening for demo.
            // Real implementation might need more robust nested map handling.
            if parts.count == 1 {
                result[key] = value
            } else {
                var dict = result
                var target = dict
                for _ in 0..<parts.count - 1 {
                    let part = parts[0]
                    target = target[part] as? [String: Any] ?? [String: Any]()
                }
                target[parts.last!] = value
                result[parts[0]] = target
            }
        }
        return result
    }
}
