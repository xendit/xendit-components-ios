//
//  PaymentAction.swift
//  XenditComponents
//
//  Created by Ahmad X on 14/04/2026.
//

import Foundation

/// UI model representing a payment action that requires user interaction.
struct PaymentAction: Identifiable, Hashable {
    let id: String
    let type: ActionType
    let value: String
    let title: String?
    let subtitle: String?
    let graphic: String?
    let otp: OtpInfo?

    enum ActionType: Hashable {
        case redirectCustomer
        case presentToCustomer
    }

    struct OtpInfo: Hashable {
        let title: String
        let instructions: String
    }
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
                title: nil,
                subtitle: nil,
                graphic: nil,
                otp: nil
            )
        case .presentToCustomer(let data):
            guard !data.value.isEmpty else { return nil }
            return PaymentAction(
                id: data.value,
                type: .presentToCustomer,
                value: data.value,
                title: data.actionTitle,
                subtitle: data.actionSubtitle,
                graphic: data.actionGraphic,
                otp: nil
            )
        case .apiPostRequest(let data):
            let otpInfo = data.otp.map { OtpInfo(title: $0.title, instructions: $0.instructions) }
            return PaymentAction(
                id: data.value,
                type: .presentToCustomer,
                value: data.value,
                title: nil,
                subtitle: nil,
                graphic: nil,
                otp: otpInfo
            )
        case .unknown:
            return nil
        }
    }
}
