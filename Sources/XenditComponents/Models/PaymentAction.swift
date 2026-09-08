//
//  PaymentAction.swift
//  XenditComponents
//
//  Created by Ahmad X on 14/04/2026.
//

import Foundation

/// UI model representing a payment action that requires user interaction.
struct PaymentAction: Identifiable {
    let id: String
    let type: ActionType
    let value: String
    /// `true` when the value is a raw QR_STRING to be rendered client-side.
    let isQrString: Bool
    /// `true` when the action presents a Virtual Account number for bank transfer.
    let isVirtualAccount: Bool
    /// `true` when the action presents a  CODE-128 barcode (PAYMENT_CODE) to be rendered client-side.
    let isBarcode: Bool
    let isDeeplink: Bool
    let title: String?
    let subtitle: String?
    let graphic: String?
    let otp: OtpInfo?
    /// Rich step-by-step instructions returned by the backend (VA, barcode, etc.).
    let instructions: [PaymentResponse.InstructionsTab]?

    enum ActionType: Hashable {
        case redirectCustomer
        case presentToCustomer
    }

    struct OtpInfo: Hashable {
        let title: String
        let instructions: String
    }
}

// Custom Hashable: instructions contains non-Hashable types; identity is sufficient.
extension PaymentAction: Hashable {
    static func == (lhs: PaymentAction, rhs: PaymentAction) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension PaymentAction {
    /// Creates a `PaymentAction` from a `PaymentResponse.Action`, or returns `nil`
    /// if the action type is not suitable for UI presentation.
    static func from(_ action: PaymentResponse.Action) -> PaymentAction? {
        switch action {
        case .redirectCustomer(let data):
            return PaymentAction(
                id: data.value,
                type: .redirectCustomer,
                value: data.value,
                isQrString: false,
                isVirtualAccount: false,
                isBarcode: false,
                isDeeplink: data.descriptor == .deeplinkUrl,
                title: nil,
                subtitle: nil,
                graphic: nil,
                otp: nil,
                instructions: nil
            )
        case .presentToCustomer(let data):
            guard !data.value.isEmpty else { return nil }
            return PaymentAction(
                id: data.value,
                type: .presentToCustomer,
                value: data.value,
                isQrString: data.descriptor == .qrString,
                isVirtualAccount: data.descriptor == .virtualAccountNumber,
                isBarcode: data.descriptor == .paymentCode,
                isDeeplink: false,
                title: data.actionTitle,
                subtitle: data.actionSubtitle,
                graphic: data.actionGraphic,
                otp: nil,
                instructions: data.instructions
            )
        case .apiPostRequest(let data):
            let otpInfo = data.otp.map { OtpInfo(title: $0.title, instructions: $0.instructions) }
            return PaymentAction(
                id: data.value,
                type: .presentToCustomer,
                value: data.value,
                isQrString: false,
                isVirtualAccount: false,
                isBarcode: false,
                isDeeplink: false,
                title: nil,
                subtitle: nil,
                graphic: nil,
                otp: otpInfo,
                instructions: nil
            )
        case .unknown:
            return nil
        }
    }
}
