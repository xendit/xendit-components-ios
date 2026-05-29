//
//  SDKStateStore.swift
//  XenditComponents
//
//  Created by Ahmad X on 03/05/2026.
//

import Foundation
import SwiftUI

@MainActor
final class SDKStateStore: ObservableObject {
    @Published var session: Session?
    @Published var businessName: String?
    @Published var customer: Customer?
    @Published var channels: [SessionResponse.Channel] = []
    @Published var channelUiGroups: [SessionResponse.ChannelUIGroup] = []
    @Published var currentChannel: SessionResponse.Channel?
    @Published var channelProperties: ChannelProperties = [:]
    @Published var sdkStatus: SDKStatus = .idle
    @Published var isSubmitting: Bool = false
    @Published var isPolling: Bool = false
    @Published var savePaymentMethod: Bool = false

    @Published var cardNumber: String = "" {
        didSet { updateDetectedScheme() }
    }
    @Published var cardDetails: CardInfoResponse? {
        didSet { updateDetectedScheme() }
    }

    @Published var phoneCountryCode: String = ""
    @Published var activeAction: PaymentAction?
    @Published var installmentPlans: [InstallmentPlan]?
    @Published var selectedInstallmentPlan: InstallmentPlan?

    /// Raw session response, kept for use in marshal functions.
    var rawSession: SessionResponse.Session?

    var isFormValid: Bool {
        guard let channel = currentChannel else { return false }
        let sessionType: SessionResponse.Session.SessionType = session?.sessionType == .pay ? .pay : .save
        let fieldsValid = FormValidator.channelPropertiesAreValid(
            fields: channel.form,
            channelProperties: channelProperties,
            sessionType: sessionType,
            showBillingDetails: cardDetails?.requireBillingInformation ?? false
        )
        guard fieldsValid else { return false }

        // Block submission if detected card brand is not in the allowed brands list
        if let allowedBrands = channel.card?.brands, !allowedBrands.isEmpty {
            let scheme = cardDetails?.schemes.first
                ?? detectCreditCardType(cardNumber.filter { $0.isNumber }).schemeName
            if let scheme,
               !allowedBrands.contains(where: { $0.name.caseInsensitiveCompare(scheme) == .orderedSame }) {
                return false
            }
        }
        return true
    }
    
    /// Detects the card network from the current `cardNumber` and updates `cardDetails.schemes`
    /// so the correct brand logo is shown immediately — before (or instead of) the BIN API response.
    private func updateDetectedScheme() {
        let digits = cardNumber.filter { $0.isNumber }
        let detectedType = detectCreditCardType(digits)

        guard let scheme = detectedType.schemeName, let existing = cardDetails else { return }
        // Only overwrite if the detected scheme differs from what is already set,
        // to avoid triggering an unnecessary @Published re-render.
        guard existing.schemes.first != scheme else { return }

        cardDetails = CardInfoResponse(
            requireBillingInformation: existing.requireBillingInformation,
            countryCodes: existing.countryCodes,
            schemes: [scheme]
        )
    }

    enum SDKStatus: Equatable {
        case idle
        case loading
        case active
        case fatalError(String)
    }
}
