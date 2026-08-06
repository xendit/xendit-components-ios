//
//  FormValidator.swift
//  XenditComponents
//
//  Created by Ahmad X on 01/05/2026.
//

import Foundation
import libPhoneNumber

// MARK: - Validation Result

enum ValidationResult: Equatable {
    case valid
    case invalid(message: String)
}

// MARK: - FormValidator

struct FormValidator {

    // MARK: - Validate for UI model field (used by FormFieldView)

    static func validate(field: Form.InputField, value: String, detectedScheme: String? = nil) -> ValidationResult {
        if value.isEmpty {
            if field.required {
                return .invalid(message: "required")
            }
            return .valid
        }

        let result: ValidationResult
        switch field.type {
        case .creditCardNumber(let brands):
            if !validateCreditCard(value) {
                result = .invalid(message: "generic_invalid")
            } else if !brands.isEmpty,
                      let scheme = detectedScheme,
                      !brands.contains(where: { $0.name.caseInsensitiveCompare(scheme) == .orderedSame }) {
                result = .invalid(message: "card_brand_not_allowed")
            } else {
                result = .valid
            }

        case .creditCardExpiry, .creditCardCvn:
            result = .valid

        case .phoneNumber:
            result = validatePhoneNumber(value)

        case .email:
            result = validateEmail(value)

        case .postalCode:
            result = validatePostalCode(value)

        case .text(let minLength, let maxLength, _, let regexValidators):
            result = validateText(
                value: value,
                minLength: minLength,
                maxLength: maxLength,
                regexValidators: regexValidators?.map { ($0.regex, $0.message) }
            )

        case .country, .province, .dropdown, .installmentPlan, .checkbox, .unknown:
            result = .valid
        }

        return result
    }

    // MARK: - Validate for response field (used by channelPropertiesAreValid)

    static func validate(field: SessionResponse.Channel.FormField, value: String) -> ValidationResult {
        if value.isEmpty {
            if field.required {
                return .invalid(message: "required")
            }
            return .valid
        }

        let result: ValidationResult
        switch field.type {
        case .creditCardNumber:
            result = validateCreditCard(value) ? .valid : .invalid(message: "generic_invalid")

        case .creditCardExpiry, .creditCardCvn:
            result = .valid

        case .phoneNumber:
            result = validatePhoneNumber(value)

        case .email:
            result = validateEmail(value)

        case .postalCode:
            result = validatePostalCode(value)

        case .text(let minLength, let maxLength, _, let regexValidators):
            result = validateText(
                value: value,
                minLength: minLength,
                maxLength: maxLength,
                regexValidators: regexValidators?.map { ($0.regex, $0.message) }
            )

        case .country, .province, .dropdown, .unknown:
            result = .valid

        case .installmentPlan:
            result = .valid
        }

        return result
    }

    // MARK: - Shared validators

    static func validateEmail(_ value: String) -> ValidationResult {
        let emailRegex = #"^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9\-]+(\.[a-zA-Z0-9\-]+)*\.[A-Za-z]{2,}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if predicate.evaluate(with: value) {
            return .valid
        }
        return .invalid(message: "generic_invalid")
    }

    static func validatePhoneNumber(_ value: String) -> ValidationResult {
        guard let phoneUtil = NBPhoneNumberUtil.sharedInstance() else {
            return .invalid(message: "generic_invalid")
        }
        do {
            // PhoneNumberFieldView always stores the value as E.164 (+dialCode + localNumber).
            // "ZZ" as the default region lets libPhoneNumber infer the region from the + prefix.
            let parsed = try phoneUtil.parse(value, defaultRegion: "ZZ")
            return phoneUtil.isValidNumber(parsed) ? .valid : .invalid(message: "generic_invalid")
        } catch {
            return .invalid(message: "generic_invalid")
        }
    }

    static func validatePostalCode(_ value: String) -> ValidationResult {
        let postalRegex = #"^(?![-\s]+)[A-Za-z0-9\s\-]+$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", postalRegex)
        if predicate.evaluate(with: value) {
            return .valid
        }
        return .invalid(message: "generic_invalid")
    }

    /// Shared text validation. regexValidators is an array of (pattern, message) tuples.
    private static func validateText(
        value: String,
        minLength: Int?,
        maxLength: Int,
        regexValidators: [(String, String)]?
    ) -> ValidationResult {
        if let validators = regexValidators {
            for (regex, message) in validators {
                let pattern = sanitizeRegex(regex)
                if let re = try? NSRegularExpression(pattern: pattern) {
                    let range = NSRange(value.startIndex..., in: value)
                    if re.firstMatch(in: value, range: range) == nil {
                        return .invalid(message: message)
                    }
                }
            }
        }

        if let min = minLength, value.count < min {
            return .invalid(message: "text_too_short")
        }
        if value.count > maxLength {
            return .invalid(message: "text_too_long")
        }
        return .valid
    }

    // MARK: - Channel Properties Validity

    static func channelPropertiesAreValid(
        fields: [SessionResponse.Channel.FormField],
        channelProperties: ChannelProperties,
        sessionType: SessionResponse.Session.SessionType,
        showBillingDetails: Bool = false
    ) -> Bool {
        let filteredFields = filterFormFields(fields, channelProperties: channelProperties, sessionType: sessionType, showBillingDetails: showBillingDetails)
        for field in filteredFields {
            let keys = field.channelProperty.keys
            for key in keys {
                let value = getChannelPropertyValue(channelProperties, key: key) ?? ""
                if case .invalid = validate(field: field, value: value) {
                    return false
                }
            }
        }
        return true
    }

    private static func sanitizeRegex(_ pattern: String) -> String {
        if pattern.hasPrefix("/") && pattern.hasSuffix("/") {
            return String(pattern.dropFirst().dropLast())
        }
        return pattern
    }
}

// MARK: - Channel Properties Helper

extension FormValidator {
    static func evaluateDisplayIf(_ conditions: [[String]]?, channelProperties: ChannelProperties) -> Bool {
        guard let conditions, !conditions.isEmpty else { return true }
        for condition in conditions {
            guard condition.count >= 3 else { continue }
            let actual = channelProperties[condition[0]] ?? ""
            switch condition[1] {
            case "equals":     if actual != condition[2] { return false }
            case "not_equals": if actual == condition[2] { return false }
            default: break
            }
        }
        return true
    }
    
    private static func getChannelPropertyValue(_ properties: ChannelProperties, key: String) -> String? {
        properties[key]
    }
    
    private static func filterFormFields(
        _ fields: [SessionResponse.Channel.FormField],
        channelProperties: ChannelProperties = [:],
        sessionType: SessionResponse.Session.SessionType,
        showBillingDetails: Bool
    ) -> [SessionResponse.Channel.FormField] {
        fields.filter { field in
            if field.flags?.requireBillingInformation == true, !showBillingDetails { return false }
            return evaluateDisplayIf(field.displayIf, channelProperties: channelProperties)
        }
    }
}

// MARK: - ChannelProperties

typealias ChannelProperties = [String: String]

// MARK: - Credit Card Validation

extension FormValidator {
    static func validateCreditCard(_ input: String) -> Bool {
        let digits = input.filter { $0.isNumber }
        return passesLuhn(digits)
    }

    private static func passesLuhn(_ digits: String) -> Bool {
        var total = 0
        let reversed = digits.reversed()
        for (offset, character) in reversed.enumerated() {
            guard let digit = character.wholeNumberValue else { return false }
            if offset % 2 == 1 {
                let doubled = digit * 2
                total += doubled > 9 ? doubled - 9 : doubled
            } else {
                total += digit
            }
        }
        return total % 10 == 0
    }
}

/// Identifies the card network based on IIN/BIN prefix and digit length.
enum CreditCardType: String {
    case visa = "VISA"
    case mastercard = "MASTERCARD"
    case amex = "AMEX"
    case discover = "DISCOVER"
    case jcb = "JCB"
    case dinersClub = "DINERS-CLUB"
    case unionPay = "UNIONPAY"
    case unknown

    /// The canonical scheme string for matching against `CardInfoResponse.schemes` and
    /// `SessionResponse.Channel.CardInfo.Brand.name`. Returns `nil` for unknown cards.
    var schemeName: String? {
        self == .unknown ? nil : rawValue
    }

    /// Name of the local image asset in `XenditComponentsUI.xcassets`.
    /// Returns `nil` when no bundled asset exists for this card network.
    var localAssetName: String? {
        switch self {
        case .visa:       return "xdt_card_visa"
        case .mastercard: return "xdt_card_mastercard"
        case .amex:       return "xdt_card_amex"
        case .jcb:        return "xdt_card_jcb"
        case .unionPay:   return "xdt_card_unionpay"
        default:          return nil   // Discover, Diners Club — no bundled asset yet
        }
    }
}
/// Validates a credit card number string using the Luhn algorithm.
/// - Parameter input: Raw card number string; whitespace and dashes are stripped before processing.
/// - Returns: `true` if the number passes the Luhn check.
func validateCreditCard(_ input: String) -> Bool {
    let digits = input.filter { $0.isNumber }
    return passesLuhn(digits)
}

// MARK: - Luhn algorithm

/// Returns `true` when the digit string satisfies the Luhn (Mod 10) checksum.
///
/// Steps:
///   1. Convert each character to its numeric value.
///   2. From the rightmost digit, double every second digit (positions 2, 4, 6, …).
///   3. If doubling produces a value ≥ 10, subtract 9 (equivalent to summing the two digits).
///   4. Sum all values; the card is valid when the total is divisible by 10.
private func passesLuhn(_ digits: String) -> Bool {
    var total = 0
    let reversed = digits.reversed()

    for (offset, character) in reversed.enumerated() {
        guard let digit = character.wholeNumberValue else { return false }

        if offset % 2 == 1 {
            // Every second digit from the right — double it.
            let doubled = digit * 2
            // If doubling overshoots 9, subtract 9 to get the digit-sum equivalent.
            total += doubled > 9 ? doubled - 9 : doubled
        } else {
            total += digit
        }
    }

    return total % 10 == 0
}
