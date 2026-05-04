//
//  InstallmentPlan.swift
//  XenditComponents
//
//  Created by Ahmad X on 14/04/2026.
//

import Foundation

/// UI model representing an installment plan option displayed to the user.
struct InstallmentPlan: Identifiable, Hashable {
    let id: String
    let terms: Int
    let interval: String
    let code: String?
    let installmentAmount: Decimal
    let totalAmount: Decimal
    let interestRate: Decimal
    let description: String
    let currency: String

    static func from(_ response: PaymentOptionsResponse.InstallmentPlan, currency: String) -> InstallmentPlan {
        InstallmentPlan(
            id: "\(response.terms)-\(response.interval)-\(response.code ?? "")",
            terms: response.terms,
            interval: response.interval,
            code: response.code,
            installmentAmount: response.installmentAmount,
            totalAmount: response.totalAmount,
            interestRate: response.interestRate,
            description: response.description,
            currency: currency
        )
    }

    static func payInFull(amount: Decimal, currency: String) -> InstallmentPlan {
        InstallmentPlan(
            id: "pay-in-full",
            terms: 0,
            interval: "",
            code: nil,
            installmentAmount: amount,
            totalAmount: amount,
            interestRate: 0,
            description: "Pay in Full",
            currency: currency
        )
    }
}
