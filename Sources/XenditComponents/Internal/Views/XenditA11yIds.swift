//
//  XenditA11yIds.swift
//  XenditComponents
//
//  Created by Ahmad X on 20/08/2026.
//

/// Centralized accessibility identifier constants for every user-interactive element.
///
/// Naming convention: `<domain>:<action_or_kind>:<identifier>` — stable across refactors,
/// always used via the constant (never hard-coded strings in tests).
///
/// Rules:
///  - Dynamic tags: concatenate a prefix constant with the identifier at the call-site.
///  - Static single-instance elements: use the raw constant directly.
internal enum XenditA11yIds {

    // ── Prefixes for dynamically-tagged form fields & options ──────────────────────────
    /// Form input field (text, card, phone, expiry, cvn). Append the form property key.
    static let formFieldPrefix = "form:field:"
    /// Form dropdown trigger (Country, Province, Installment, generic Dropdown). Append the form property key.
    static let formDropdownPrefix = "form:dropdown:"
    /// Selectable item inside a picker sheet. Append the option value/code.
    static let optionPrefix = "option:item:"
    /// Search input field inside a picker sheet. Append sheet kind.
    static let pickerSearchPrefix = "picker:search:"
    /// Channel / payment method row in the selector. Append channel code or UI-group id.
    static let channelPrefix = "channel:row:"

    // ── XenditSheetView: global sheet root & CTA ──────────────────────────────────────
    static let paymentSheet = "payment:sheet:root"
    static let dialogSubmitButton = "button:submit:pay"
    static let dialogErrorCloseButton = "button:error:close"
    static let genericHeaderLeadingButton = "button:header:leading"

    // ── Checkbox ──────────────────────────────────────────────────────────────────────
    static let saveCardCheckbox = "checkbox:save_card"

    // ── Awaiting-payment overlay ───────────────────────────────────────────────────────
    static let awaitingPaymentDialogClose = "button:awaiting_payment:close"

    // ── Country picker ────────────────────────────────────────────────────────────────
    static let countryPickerSheet = "picker:country:sheet"
    static let countryPickerSheetClose = "button:picker:country:close"
    static let countryPickerSearch = pickerSearchPrefix + "country"

    // ── Province picker ───────────────────────────────────────────────────────────────
    static let provincePickerSheet = "picker:province:sheet"
    static let provincePickerSheetClose = "button:picker:province:close"
    static let provincePickerSearch = pickerSearchPrefix + "province"

    // ── Installment & generic dropdown ─────────────────────────────────────────────────
    static let installmentPlanTrigger = "form:dropdown:installment_plan"
    /// The bottom-sheet container for a generic dropdown (XenditDropdownField equivalent).
    static let dropdownMenu = "dropdown:menu:sheet"
    /// Selectable item inside a generic dropdown sheet. Append the option value.
    static let dropdownMenuItemPrefix = "dropdown:menu:item:"

    // ── Phone number country-code chip ─────────────────────────────────────────────────
    static let phoneCountryCodeTrigger = "picker:phone_country_code:trigger"
}

import SwiftUI

extension View {
    /// Applies `.accessibilityIdentifier` only when `id` is non-empty.
    @ViewBuilder
    func accessibilityIdentifierIfSet(_ id: String) -> some View {
        if id.isEmpty { self } else { self.accessibilityIdentifier(id) }
    }
}
