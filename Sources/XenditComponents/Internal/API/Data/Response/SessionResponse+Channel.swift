//
//  SessionResponse+Channel.swift
//  XenditComponents
//
//  Created by Ahmad X on 04/04/2026.
//

import Foundation

extension SessionResponse {
    struct Channel: Decodable {
        let brandName: String
        let channelCode: String
        let pmType: PaymentMethod?
        let brandLogoUrl: String
        let uiGroup: String
        let allowPayWithoutSave: Bool
        let allowSave: Bool
        let brandColor: String
        let minAmount: Decimal?
        let maxAmount: Decimal?
        let requiresCustomerDetails: Bool?
        let form: [FormField]
        let banner: Banner?
        let instructions: [String]?
        
        //Card
        let card: CardInfo?

        enum CodingKeys: String, CodingKey {
            case brandName = "brand_name"
            case channelCode = "channel_code"
            case pmType = "pm_type"
            case brandLogoUrl = "brand_logo_url"
            case uiGroup = "ui_group"
            case allowPayWithoutSave = "allow_pay_without_save"
            case allowSave = "allow_save"
            case brandColor = "brand_color"
            case minAmount = "min_amount"
            case maxAmount = "max_amount"
            case requiresCustomerDetails = "requires_customer_details"
            case form, banner, instructions
            case card
        }
    }
}

extension SessionResponse.Channel {
    enum PaymentMethod: String, Decodable {
        case cards = "CARDS"
        case qrCode = "QR_CODE"
        case overTheCounter = "OVER_THE_COUNTER"
        case ewallet = "EWALLET"
        case bankTransfer = "BANK_TRANSFER"
        case directDebit = "DIRECT_DEBIT"
        case virtualAccount = "VIRTUAL_ACCOUNT"
        case onlineBanking = "ONLINE_BANKING"
        /// Received when the backend introduces a payment method not yet known to this SDK version.
        case unknown

        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            self = Self(rawValue: raw) ?? .unknown
        }
    }
}

// MARK: - Form

extension SessionResponse.Channel {
    struct FormField: Decodable {
        let groupLabel: String?
        let label: String
        let placeholder: String
        let type: FieldType
        let channelProperty: ChannelProperty
        let required: Bool
        let span: Int
        let join: Bool?
        let initialValue: String?
        let disabled: Bool?
        let displayIf: [[String]]?
        let flags: Flags?

        enum CodingKeys: String, CodingKey {
            case groupLabel = "group_label"
            case label
            case placeholder, type
            case channelProperty = "channel_property"
            case required, span, join
            case initialValue = "initial_value"
            case disabled
            case displayIf = "display_if"
            case flags
        }
    }
}

extension SessionResponse.Channel.FormField {
    struct Flags: Decodable {
        let requireBillingInformation: Bool?

        enum CodingKeys: String, CodingKey {
            case requireBillingInformation = "require_billing_information"
        }
    }

}

/**
   * Where to write the property in the channel properties object.
   * Can be dot-separated to write to a nested object.
   * Can be an array for components that expose multiple values.
   *
   * @example
   * "billing_information.street_line1" -> { billing_information: { street_line1: "value" } }
   * ["expiry_month", "expiry_year"] -> { expiry_month: "value1", expiry_year: "value2" }
   **/

extension SessionResponse.Channel.FormField {
    enum ChannelProperty: Decodable {
        case single(String)
        case multiple([String])

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let string = try? container.decode(String.self) {
                self = .single(string)
            } else {
                let array = try container.decode([String].self)
                self = .multiple(array)
            }
        }

        var keys: [String] {
            switch self {
            case .single(let key): return [key]
            case .multiple(let keys): return keys
            }
        }

        var primaryKey: String {
            keys[0]
        }
    }
}

extension SessionResponse.Channel.FormField {
    enum FieldType: Decodable {
        case creditCardNumber
        case creditCardExpiry
        case creditCardCvn
        case phoneNumber
        case email
        case postalCode
        case country
        case province
        case installmentPlan
        case text(minLength: Int?, maxLength: Int, numeric: Bool?, regexValidators: [RegexValidator]?)
        case dropdown(options: [DropdownOption])
        case unknown(String)

        enum CodingKeys: String, CodingKey {
            case name
            case minLength = "min_length"
            case maxLength = "max_length"
            case numeric
            case regexValidators = "regex_validators"
            case options
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let name = try container.decode(String.self, forKey: .name)
            switch name {
            case "credit_card_number":
                self = .creditCardNumber
            case "credit_card_expiry":
                self = .creditCardExpiry
            case "credit_card_cvn":
                self = .creditCardCvn
            case "phone_number":
                self = .phoneNumber
            case "email":
                self = .email
            case "postal_code":
                self = .postalCode
            case "country":
                self = .country
            case "province":
                self = .province
            case "installment_plan":
                self = .installmentPlan
            case "text":
                let minLength = try container.decodeIfPresent(Int.self, forKey: .minLength)
                let maxLength = try container.decode(Int.self, forKey: .maxLength)
                let numeric = try container.decodeIfPresent(Bool.self, forKey: .numeric)
                let regexValidators = try container.decodeIfPresent([RegexValidator].self, forKey: .regexValidators)
                self = .text(minLength: minLength, maxLength: maxLength, numeric: numeric, regexValidators: regexValidators)
            case "dropdown":
                let options = try container.decode([DropdownOption].self, forKey: .options)
                self = .dropdown(options: options)
            default:
                self = .unknown(name)
            }
        }

        var name: String {
            switch self {
            case .creditCardNumber: return "credit_card_number"
            case .creditCardExpiry: return "credit_card_expiry"
            case .creditCardCvn: return "credit_card_cvn"
            case .phoneNumber: return "phone_number"
            case .email: return "email"
            case .postalCode: return "postal_code"
            case .country: return "country"
            case .province: return "province"
            case .installmentPlan: return "installment_plan"
            case .text: return "text"
            case .dropdown: return "dropdown"
            case .unknown(let name): return name
            }
        }

    }
}

extension SessionResponse.Channel.FormField.FieldType {
    struct RegexValidator: Decodable {
        let regex: String
        let message: String
    }
    
    struct DropdownOption: Decodable {
        let label: String
        let subtitle: String?
        let iconUrl: String?
        let value: String

        enum CodingKeys: String, CodingKey {
            case label, subtitle, value
            case iconUrl = "icon_url"
        }
    }
}

extension SessionResponse.Channel {
    func parse(allowSavePaymentMethod: SessionResponse.Session.AllowSavePaymentMethod?, businessName: String? = nil, hasSaveVariant: Bool = false) -> Form.Page {
        var sections: [Form.Section] = []
        var currentTitle: String? = nil
        var currentComponents: [Form.Component] = []
        // Use a stable section ID derived from the title (or a fixed default for the first section)
        var currentSectionId: String = "section_default"
        // Holds a lone span=1 field waiting to be paired into a .row
        var pendingHalfField: Form.Component? = nil
        // Installment plan components are pulled out of the normal flow and
        // placed in their own section just before the save-payment-method checkbox.
        var installmentPlanComponents: [Form.Component] = []

        func flushPendingHalfField() {
            if let pending = pendingHalfField {
                currentComponents.append(pending)
                pendingHalfField = nil
            }
        }

        func joinValue(of component: Form.Component) -> Bool {
            switch component {
            case .inputField(let f): return f.join
            case .row(let comps, _, _):
                guard case .inputField(let f) = comps.first else { return false }
                return f.join
            }
        }

        func commitSection() {
            flushPendingHalfField()
            // Propagate join forward: if component[i+1] has join=true and component[i] has join=false,
            // update component[i] to join=true so it renders as part of the same grouped card.
            for i in currentComponents.indices.dropLast() {
                if !joinValue(of: currentComponents[i]) && joinValue(of: currentComponents[i + 1]) {
                    currentComponents[i] = forceJoin(currentComponents[i])
                }
            }
            if !currentComponents.isEmpty {
                sections.append(Form.Section(
                    id: currentSectionId,
                    title: currentTitle,
                    isHidden: false,
                    components: currentComponents
                ))
            }
        }

        for field in form {
            // A present groupLabel starts a new section
            if let groupLabel = field.groupLabel {
                commitSection()
                currentTitle = groupLabel
                // Stable section ID derived from the group label
                currentSectionId = "section_\(groupLabel)"
                currentComponents = []
            }

            let inputField = Form.InputField(
                // Stable ID derived from the channel property key — avoids recreating
                // views on every re-render due to changing UUIDs.
                id: field.channelProperty.primaryKey,
                type: mapInputType(field.type),
                label: field.label.isEmpty ? nil : field.label,
                placeholder: field.placeholder.isEmpty ? nil : field.placeholder,
                required: field.required,
                isDisabled: field.disabled ?? false,
                initialValue: field.initialValue,
                channelProperty: mapChannelProperty(field.channelProperty),
                flags: Form.Flags(requireBillingInformation: field.flags?.requireBillingInformation),
                join: field.join ?? false,
                displayIf: field.displayIf
            )
            let component = Form.Component.inputField(field: inputField)

            // Installment plan gets its own section — skip normal placement.
            if case .installmentPlan = field.type {
                installmentPlanComponents.append(component)
                continue
            }

            if field.span == 1 {
                // Two consecutive span=1 fields are grouped into a single .row component.
                // Both fields get join = true so the row renders as a single grouped card.
                if let pending = pendingHalfField {
                    currentComponents.append(.row(
                        components: [forceJoin(pending), forceJoin(component)],
                        alignment: .top, spacing: 8
                    ))
                    pendingHalfField = nil
                } else {
                    pendingHalfField = component
                }
            } else {
                flushPendingHalfField()
                currentComponents.append(component)
            }
        }

        // Commit the last section
        commitSection()

        // Insert installment plan section before the checkbox (or at the bottom if no checkbox).
        if !installmentPlanComponents.isEmpty {
            sections.append(Form.Section(
                id: "section_installment_plan",
                title: nil,
                isHidden: false,
                components: installmentPlanComponents
            ))
        }

        // Append save payment method checkbox at the bottom if applicable
        if (allowSave || hasSaveVariant), allowSavePaymentMethod != .disabled {
            let isChecked = allowSavePaymentMethod == .forced
            let isEnabled = allowSavePaymentMethod == .optional
            let checkboxVariant: Form.CheckboxVariant
            if pmType == .ewallet {
                checkboxVariant = .eWallet(brandName: brandName, businessName: businessName ?? "")
            } else {
                checkboxVariant = .card
            }
            let checkboxField = Form.InputField(
                id: "allow_save_payment_method",
                type: .checkbox(isChecked: isChecked, isEnabled: isEnabled, variant: checkboxVariant),
                label: nil,
                placeholder: nil,
                required: false,
                isDisabled: !isEnabled,
                initialValue: nil,
                channelProperty: .single("allow_save_payment_method"),
                flags: Form.Flags(requireBillingInformation: nil),
                join: false,
                displayIf: nil
            )
            sections.append(Form.Section(
                id: "section_save_payment_method",
                title: nil,
                isHidden: false,
                components: [.inputField(field: checkboxField)]
            ))
        }

        return Form.Page(sections: sections)
    }

    // MARK: - Mapping helpers

    private func mapInputType(_ type: FormField.FieldType) -> Form.InputType {
        switch type {
        case .creditCardNumber:  return .creditCardNumber(brands: self.card?.brands.map { Form.CardBrand(name: $0.name, logoUrl: $0.logoUrl) } ?? [])
        case .creditCardExpiry:  return .creditCardExpiry
        case .creditCardCvn:     return .creditCardCvn
        case .phoneNumber:       return .phoneNumber
        case .email:             return .email
        case .postalCode:        return .postalCode
        case .country:           return .country
        case .province:          return .province
        case .installmentPlan:   return .installmentPlan
        case .unknown(let name): return .unknown(name)
        case .text(let min, let max, let numeric, let validators):
            return .text(
                minLength: min,
                maxLength: max,
                numeric: numeric,
                regexValidators: validators?.map { Form.RegexValidator(regex: $0.regex, message: $0.message) }
            )
        case .dropdown(let options):
            return .dropdown(options: options.map {
                Form.DropdownOption(label: $0.label, subtitle: $0.subtitle, iconUrl: $0.iconUrl, value: $0.value)
            })
        }
    }

    private func mapChannelProperty(_ property: FormField.ChannelProperty) -> Form.ChannelProperty {
        switch property {
        case .single(let key):    return .single(key)
        case .multiple(let keys): return .multiple(keys)
        }
    }

    /// Returns a copy of `component` with `join = true` on its InputField (if applicable).
    private func forceJoin(_ component: Form.Component) -> Form.Component {
        guard case .inputField(let f) = component else { return component }
        return .inputField(field: Form.InputField(
            id: f.id, type: f.type, label: f.label, placeholder: f.placeholder,
            required: f.required, isDisabled: f.isDisabled, initialValue: f.initialValue,
            channelProperty: f.channelProperty, flags: f.flags, join: true,
            displayIf: f.displayIf
        ))
    }
}

// MARK: - Amount Range

extension SessionResponse.Channel {
    func isInAmountRange(for sessionType: SessionResponse.Session.SessionType, amount: Decimal) -> Bool {
        guard sessionType == .pay else { return true }
        if let min = minAmount, amount < min { return false }
        if let max = maxAmount, amount > max { return false }
        return true
    }
    
    func amountDisabledReason(for sessionType: SessionResponse.Session.SessionType, amount: Decimal, locale: String) -> String? {
        guard !isInAmountRange(for: sessionType, amount: amount) else { return nil }
        let strings = XenditStrings(locale: locale)
        if let min = minAmount, amount < min {
            return strings.string(for: .paymentMethodsChannelDisabledAmountTooSmall)
        }
        return strings.string(for: .paymentMethodsChannelDisabledAmountTooLarge)
    }
}

// MARK: - Banner

extension SessionResponse.Channel {
    ///banner to display between form and instructions, spans full width
    struct Banner: Codable {
        let imageUrl: String
        let altText: String
        let linkUrl: String?
        let aspectRatio: Double?

        enum CodingKeys: String, CodingKey {
            case imageUrl = "image_url"
            case altText = "alt_text"
            case linkUrl = "link_url"
            case aspectRatio = "aspect_ratio"
        }
    }
}

// MARK: - Card Info

extension SessionResponse.Channel {
    struct CardInfo: Codable {
        let brands: [Brand]
    }
}

extension SessionResponse.Channel.CardInfo {
    struct Brand: Codable {
        let name: String
        let logoUrl: String

        enum CodingKeys: String, CodingKey {
            case name
            case logoUrl = "logo_url"
        }
    }
}
