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
    @Published var customer: Customer?
    @Published var channels: [SessionResponse.Channel] = []
    @Published var channelUiGroups: [SessionResponse.ChannelUIGroup] = []
    @Published var currentChannel: SessionResponse.Channel?
    @Published var channelProperties: ChannelProperties = [:]
    @Published var sdkStatus: SDKStatus = .idle
    @Published var isSubmitting: Bool = false
    @Published var isPolling: Bool = false
    @Published var savePaymentMethod: Bool = false

    @Published var cardNumber: String = ""
    @Published var cardDetails: CardInfoResponse?

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

        // Block submission if the API-confirmed card scheme is not in the allowed brands list.
        // If cardDetails has not arrived yet, skip the check and allow submission to proceed.
        if let allowedBrands = channel.card?.brands, !allowedBrands.isEmpty,
           let scheme = cardDetails?.schemes.first,
           !allowedBrands.contains(where: { $0.name.caseInsensitiveCompare(scheme) == .orderedSame }) {
            return false

        }
        return true
    }

    enum SDKStatus: Equatable {
        case idle
        case loading
        case active
        case fatalError(String)
    }
}
