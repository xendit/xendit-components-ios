//
//  PhoneNumberFieldView.swift
//  XenditComponents
//
//  Created by Ahmad X on 01/05/2026.
//

import SwiftUI
import UIKit

struct PhoneNumberFieldView: View {
    let label: String
    let placeholder: String
    @Binding var value: String
    var isDisabled: Bool = false
    /// Direct country-code override (e.g. "CA"). When non-empty, applied immediately
    /// without guessing from the dial-code prefix, which is ambiguous for shared codes like +1.
    var externalCountryCode: String = ""
    var onChanged: (() -> Void)?
    var onEditingEnded: (() -> Void)?

    // Stored as code string so it can be bound to XenditPickerSheet directly.
    @State private var selectedCountryCode: String = "ID"
    @State private var localNumber: String = ""
    @State private var isCountryPickerPresented = false

    private var selectedCountry: Country {
        Country.fromCode(selectedCountryCode) ?? Country.countries[0]
    }

    // Mapped once — source data never changes.
    private static let countryOptions: [BottomSheetPickerFieldView.PickerOption] = Country.countries.map {
        BottomSheetPickerFieldView.PickerOption(label: $0.name, subtitle: "+\($0.dialCode)", value: $0.code, iconUrl: $0.flagUrl)
    }

    var body: some View {
        XenditLabeledField(label: label, spacing: Spacing.s3) {
            HStack(spacing: Spacing.s2) {
                Button {
                    guard !isDisabled else { return }
                    isCountryPickerPresented = true
                } label: {
                    HStack(spacing: Spacing.s1) {
                        RemoteImage(url: URL(string: selectedCountry.flagUrl))
                            .frame(width: 16, height: 16)
                            .clipShape(Circle())

                        Text("+\(selectedCountry.dialCode)")
                            .font(.labelLgRegular)
                            .foregroundColor(.Text.default)

                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                            .foregroundColor(.Text.default)
                    }
                    .padding(.horizontal, Spacing.s3)
                    .frame(minWidth: 80, minHeight: 44)
                    .xenditFieldBorder()
                }
                .buttonStyle(.plain)
                .disabled(isDisabled)

                TextField(placeholder, text: $localNumber)
                    .font(.labelLgRegular)
                    .keyboardType(.phonePad)
                    .disabled(isDisabled)
                    .padding(.horizontal, Spacing.s3)
                    .frame(height: 44)
                    .xenditFieldBorder()
                    .onChange(of: localNumber) { _ in updateFullValue() }
                    .onSubmit { onEditingEnded?() }
            }
        }
        .onAppear {
            parseInitialValue()
        }
        .onChange(of: externalCountryCode) { code in
            guard !code.isEmpty, selectedCountryCode != code else { return }
            selectedCountryCode = code
            updateFullValue()
        }
        .onChange(of: value) { newValue in
            syncFromExternalValue(newValue)
        }
        .sheet(isPresented: $isCountryPickerPresented) {
            XenditPickerSheet(
                title: "Select Country",
                options: Self.countryOptions,
                value: $selectedCountryCode,
                searchEnabled: true,
                searchPlaceholder: "Search country or dial code",
                searchFilter: { query, option in
                    option.label.localizedCaseInsensitiveContains(query) ||
                    (option.subtitle ?? "").contains(query)
                },
                onSelected: { code in
                    selectedCountryCode = code
                    updateFullValue()
                }
            )
            .modifier(SheetDetentsModifier())
        }
    }

    private func parseInitialValue() {
        if value.hasPrefix("+") {
            for country in Country.countriesByDialCodeLength {
                let prefix = "+\(country.dialCode)"
                if value.hasPrefix(prefix) {
                    selectedCountryCode = country.code
                    localNumber = String(value.dropFirst(prefix.count))
                    return
                }
            }
        }
        localNumber = value
    }

    /// Called when the binding is mutated externally (e.g. by handleCardDetailsResolved).
    /// Mirrors parseInitialValue but guards each assignment so unchanged state doesn't
    /// trigger onChange(of: localNumber) → updateFullValue() loops.
    private func syncFromExternalValue(_ newValue: String) {
        if newValue.hasPrefix("+") {
            for country in Country.countriesByDialCodeLength {
                let prefix = "+\(country.dialCode)"
                if newValue.hasPrefix(prefix) {
                    let newLocal = String(newValue.dropFirst(prefix.count))
                    // Skip country inference when an external code is active — dial-code
                    // prefixes are ambiguous (e.g. +1 matches both US and CA).
                    if externalCountryCode.isEmpty, selectedCountryCode != country.code {
                        selectedCountryCode = country.code
                    }
                    if localNumber != newLocal { localNumber = newLocal }
                    return
                }
            }
        } else if localNumber != newValue {
            localNumber = newValue
        }
    }

    private func updateFullValue() {
        value = "+\(selectedCountry.dialCode)\(localNumber)"
        onChanged?()
    }
}
