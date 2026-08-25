//
//  SessionResponse+DigitalWallets.swift
//  XenditComponents
//
//  Created by Ahmad X on 24/08/2026.
//

import Foundation

extension SessionResponse {
    struct DigitalWallets: Decodable {
        let applePay: ApplePay?

        enum CodingKeys: String, CodingKey {
            case applePay = "apple_pay"
        }
    }
}

extension SessionResponse.DigitalWallets {
    struct ApplePay: Decodable {
        let merchantId: String
        let applePayPaymentRequest: PaymentRequest

        enum CodingKeys: String, CodingKey {
            case merchantId = "merchant_id"
            case applePayPaymentRequest = "apple_pay_payment_request"
        }

        struct PaymentRequest: Decodable {
            let countryCode: String
            let currencyCode: String
            let merchantCapabilities: [String]
            let supportedNetworks: [String]
            let total: LineItem
            let requiredBillingContactFields: [String]?
            let requiredShippingContactFields: [String]?

            struct LineItem: Decodable {
                let label: String
                let amount: String
                let type: String?
            }
        }
    }
}
