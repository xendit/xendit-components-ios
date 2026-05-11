//
//  PaymentOptionsResponse.swift
//  XenditComponents
//
//  Created by Ahmad X on 05/04/2026.
//

import Foundation

struct PaymentOptionsResponse: Decodable {
    let channelCode: String
    let country: String
    let currency: String
    let amount: Decimal
    let installmentPlans: [InstallmentPlan]?
    let paylaterPlans: [PaylaterPlan]?
    
    enum CodingKeys: String, CodingKey {
        case country, currency, amount
        case channelCode = "channel_code"
        case installmentPlans = "installment_plans"
        case paylaterPlans = "paylater_plans"
    }
}

extension PaymentOptionsResponse {
    struct InstallmentPlan: Decodable {
        let interval: String
        let intervalCount: Int
        let terms: Int
        let installmentAmount: Decimal
        let totalAmount: Decimal
        let code: String?
        let interestRate: Decimal
        let description: String
        
        enum CodingKeys: String, CodingKey {
            case interval, terms, code, description
            case intervalCount = "interval_count"
            case installmentAmount = "installment_amount"
            case totalAmount = "total_amount"
            case interestRate = "interest_rate"
        }
    }
    
    struct PaylaterPlan: Decodable {
        let interval: String?
        let intervalCount: Int?
        let terms: Int?
        let installmentAmount: Decimal?
        let totalAmount: Decimal?
        let interestRate: Decimal?
        let description: String?
        let downpaymentAmount: Decimal?
        
        enum CodingKeys: String, CodingKey {
            case interval, terms, description
            case intervalCount = "interval_count"
            case installmentAmount = "installment_amount"
            case totalAmount = "total_amount"
            case interestRate = "interest_rate"
            case downpaymentAmount = "downpayment_amount"
        }
    }
}
