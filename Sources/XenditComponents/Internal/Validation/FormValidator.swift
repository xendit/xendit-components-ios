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

    static func validate(field: Form.InputField, value: String) -> ValidationResult {
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
            } else if !brands.isEmpty {
                let digits = value.filter { $0.isNumber }
                let detected = detectCreditCardType(digits)
                if let scheme = detected.schemeName,
                   !brands.contains(where: { $0.name.caseInsensitiveCompare(scheme) == .orderedSame }) {
                    result = .invalid(message: "card_brand_not_supported")
                } else {
                    result = .valid
                }
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
        let filteredFields = filterFormFields(fields, sessionType: sessionType, showBillingDetails: showBillingDetails)
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

func getChannelPropertyValue(_ properties: ChannelProperties, key: String) -> String? {
    if let value = properties[key] {
        return value
    }
    return nil
}

func filterFormFields(
    _ fields: [SessionResponse.Channel.FormField],
    sessionType: SessionResponse.Session.SessionType,
    showBillingDetails: Bool
) -> [SessionResponse.Channel.FormField] {
    fields.filter { field in
        if field.flags?.requireBillingInformation == true {
            if !showBillingDetails { return false }
        }
        return true
    }
}

// MARK: - ChannelProperties

typealias ChannelProperties = [String: String]

// MARK: - Credit Card Validation

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
//NOTE: put it in UTIL or Helper folder
/// Validates a credit card number string using the Luhn algorithm and card-type rules.
///
/// - Parameter input: Raw card number string; whitespace and dashes are stripped before processing.
/// - Returns: `true` if the number passes the Luhn check **and** matches the expected length and
///   prefix for its detected card type.
func validateCreditCard(_ input: String) -> Bool {
    // 1. Sanitize: remove spaces and dashes so the caller doesn't have to pre-clean the string.
    let digits = input.filter { $0.isNumber }

    // 2. Detect card type from IIN/BIN prefix.
    let type = detectCreditCardType(digits)

    // 3. Verify the digit count matches what the card network requires.
    guard isValidLength(digits, for: type) else { return false }

    // 4. Run the Luhn (Mod 10) check.
    return passesLuhn(digits)
}

// MARK: - Card type detection

func detectCreditCardType(_ digits: String) -> CreditCardType {
    // All prefix checks use `hasPrefix` on the raw digit string — O(k) where k is prefix length,
    // no regex compilation overhead.

    if digits.hasPrefix("4") {
        return .visa
    }

    // Mastercard: prefixes 51–55 or 2221–2720.
    if let twoDigit = Int(digits.prefix(2)), (51...55).contains(twoDigit) {
        return .mastercard
    }
    if let fourDigit = Int(digits.prefix(4)), (2221...2720).contains(fourDigit) {
        return .mastercard
    }

    // Amex: prefixes 34 or 37.
    if digits.hasPrefix("34") || digits.hasPrefix("37") {
        return .amex
    }

    // Discover: prefix 6011, 65, or 644–649.
    if digits.hasPrefix("6011") || digits.hasPrefix("65") {
        return .discover
    }
    if let threeDigit = Int(digits.prefix(3)), (644...649).contains(threeDigit) {
        return .discover
    }

    // JCB: prefixes 3528–3589.
    if let fourDigit = Int(digits.prefix(4)), (3528...3589).contains(fourDigit) {
        return .jcb
    }

    // Diners Club International: 300–305, 36, 38.
    // Diners Club North America (co-branded): 54.
    if let threeDigit = Int(digits.prefix(3)), (300...305).contains(threeDigit) {
        return .dinersClub
    }
    if digits.hasPrefix("36") || digits.hasPrefix("38") || digits.hasPrefix("54") {
        return .dinersClub
    }

    // UnionPay: prefix 62 or 81.
    if digits.hasPrefix("62") || digits.hasPrefix("81") {
        return .unionPay
    }

    return .unknown
}

// MARK: - Length check

private func isValidLength(_ digits: String, for type: CreditCardType) -> Bool {
    let count = digits.count
    switch type {
    case .visa:        return count == 13 || count == 16 || count == 19
    case .mastercard:  return count == 16
    case .amex:        return count == 15
    case .discover:    return count == 16 || count == 19
    case .jcb:         return (16...19).contains(count)
    case .dinersClub:  return count == 14 || count == 16   // 14 = International, 16 = North America
    case .unionPay:    return (16...19).contains(count)
    case .unknown:     return false   // reject unrecognized card networks
    }
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
