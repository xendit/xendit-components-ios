//
//  FormFieldView.swift
//  XenditComponents
//
//  Created by Ahmad X on 02/05/2026.
//

import SwiftUI

struct FormFieldView: View {
    let field: Form.InputField
    @Binding var value: String
    let locale: String
    var cardType: CreditCardType? = nil
    var installmentPlans: [InstallmentPlan]? = nil
    var selectedCountry: String = ""
    var phoneCountryCode: String = ""
    var onChanged: (() -> Void)?
    var onValidationChanged: ((String?) -> Void)? = nil

    @State private var isTouched: Bool = false

    private var strings: XenditStrings {
        XenditStrings(locale: locale)
    }

    /// Empty string when `join == true` so the field view hides its label.
    private var effectiveLabel: String {
        field.join ? "" : (field.label ?? "")
    }

    private var validationError: String? {
        guard isTouched else { return nil }
        let result = FormValidator.validate(field: field, value: value)
        switch result {
        case .valid:
            return nil
        case .invalid(let code):
            let fieldLabel = field.label ?? effectiveLabel
            return strings.validationMessage(forCode: code, fieldLabel: fieldLabel) ?? code
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s1) {
            fieldContent
                .environment(\.xenditFieldHasError, validationError != nil)
            if !field.join, let error = validationError {
                Text(error)
                    .font(InterFont.captionRegular)
                    .foregroundColor(XenditComponents.appearance.resolvedDanger)
            }
        }
        .onChange(of: isTouched) { _ in onValidationChanged?(validationError) }
        .onChange(of: value) { _ in
            guard isTouched else { return }
            onValidationChanged?(validationError)
        }
    }

    @ViewBuilder
    private var fieldContent: some View {
        switch field.type {
        case .creditCardNumber(let brands):
            CreditCardNumberFieldView(
                label: effectiveLabel,
                placeholder: field.placeholder ?? "",
                brands: brands,
                value: $value,
                isDisabled: field.isDisabled,
                cardType: cardType,
                onChanged: handleChanged,
                onEditingEnded: { isTouched = true }
            )

        case .email:
            TextInputFieldView(
                label: effectiveLabel,
                placeholder: field.placeholder ?? "",
                value: $value,
                keyboardType: .emailAddress,
                isDisabled: field.isDisabled,
                onChanged: handleChanged,
                onEditingEnded: { isTouched = true }
            )

        case .phoneNumber:
            PhoneNumberFieldView(
                label: effectiveLabel,
                placeholder: field.placeholder ?? "",
                value: $value,
                isDisabled: field.isDisabled,
                externalCountryCode: phoneCountryCode,
                onChanged: handleChanged,
                onEditingEnded: { isTouched = true }
            )

        case .text(_, _, let numeric, _):
            TextInputFieldView(
                label: effectiveLabel,
                placeholder: field.placeholder ?? "",
                value: $value,
                keyboardType: numeric == true ? .numberPad : .default,
                isDisabled: field.isDisabled,
                onChanged: handleChanged,
                onEditingEnded: { isTouched = true }
            )

        case .postalCode:
            TextInputFieldView(
                label: effectiveLabel,
                placeholder: field.placeholder ?? "",
                value: $value,
                keyboardType: .numbersAndPunctuation,
                isDisabled: field.isDisabled,
                onChanged: handleChanged,
                onEditingEnded: { isTouched = true }
            )

        case .creditCardExpiry:
            CreditCardExpiryFieldView(
                label: effectiveLabel,
                placeholder: field.placeholder ?? "",
                value: $value,
                isDisabled: field.isDisabled,
                onChanged: handleChanged,
                onEditingEnded: { isTouched = true }
            )

        case .creditCardCvn:
            CreditCardCvnFieldView(
                label: effectiveLabel,
                placeholder: field.placeholder ?? "",
                value: $value,
                isDisabled: field.isDisabled,
                onChanged: handleChanged,
                onEditingEnded: { isTouched = true }
            )

        case .dropdown(let options):
            DropdownFieldView(
                label: effectiveLabel,
                placeholder: field.placeholder ?? "",
                options: options.map { DropdownFieldView.Option(label: $0.label, value: $0.value, subtitle: $0.subtitle) },
                value: $value,
                isDisabled: field.isDisabled,
                onChanged: handleChanged
            )

        case .country:
            CountryFieldView(
                label: effectiveLabel,
                placeholder: field.placeholder ?? "",
                value: $value,
                isDisabled: field.isDisabled,
                onChanged: handleChanged
            )

        case .province:
            ProvinceFieldView(
                label: effectiveLabel,
                placeholder: field.placeholder ?? "",
                selectedCountry: selectedCountry,
                value: $value,
                isDisabled: field.isDisabled,
                onChanged: handleChanged
            )

        case .installmentPlan:
            // Hidden entirely when no plans are available (guard also in ChannelFormView.shouldShow).
            // The encoded value "terms|interval|code" lets InstallmentPlanFieldMapper
            // write all three channel properties from a single bottom-sheet selection.
            if let plans = installmentPlans, !plans.isEmpty {
                let options: [BottomSheetPickerFieldView.PickerOption] = plans.map { plan in
                    let encoded = "\(plan.terms)|\(plan.interval)|\(plan.code ?? "")"
                    return BottomSheetPickerFieldView.PickerOption(
                        label: plan.altDescription,
                        subtitle: nil,
                        value: encoded
                    )
                }
                BottomSheetPickerFieldView(
                    label: effectiveLabel,
                    placeholder: field.placeholder ?? "",
                    options: options,
                    value: $value,
                    isDisabled: field.isDisabled,
                    onChanged: handleChanged
                )
            }

        case .checkbox(let isChecked, let isEnabled):
            CheckboxFieldView(
                isChecked: Binding(
                    get: { value == "true" },
                    set: { value = $0 ? "true" : "false"; handleChanged() }
                ),
                isEnabled: isEnabled,
                locale: locale
            )
            .onAppear {
                // Initialise from the parsed isChecked state if not yet set
                if value.isEmpty {
                    value = isChecked ? "true" : "false"
                }
            }

        default:
            TextInputFieldView(
                label: effectiveLabel,
                placeholder: field.placeholder ?? "",
                value: $value,
                keyboardType: .default,
                isDisabled: field.isDisabled,
                onChanged: handleChanged,
                onEditingEnded: { isTouched = true }
            )
        }
    }

    private func handleChanged() {
        isTouched = true
        onChanged?()
    }
}

// MARK: Convenience

private extension InstallmentPlan {
    var altDescription: String {
        let amount = terms == 0 ? totalAmount : installmentAmount
        if terms == 0 {
            return "\(description) \u{2014} \(formattedAmount(amount))"
        } else {
            return "\(terms)x Installments \u{2014} \(formattedAmount(amount))"

        }
    }

    private func formattedAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        if currency == "IDR" {
            formatter.locale = Locale(identifier: "id_ID")
        }
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(currency)\(amount)"
    }
}
