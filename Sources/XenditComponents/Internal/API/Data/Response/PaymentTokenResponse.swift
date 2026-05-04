//
//  PaymentTokenResponse.swift
//  XenditComponents
//
//  Created by Ahmad X on 04/04/2026.
//

import Foundation

struct PaymentTokenResponse: Decodable {
    let paymentTokenId: String
    let businessId: String?
    let customerId: String?
    let country: String?
    let referenceId: String?
    let currency: String?
    let status: PaymentTokenStatus
    let actions: [PaymentResponse.Action]
    let failureCode: String?  //TODO: Use string instead of enum. Flexibility when new enum introduce no need to update and there is no action for now for failure code
    let created: Date?
    let updated: Date?
    let channelCode: String

    ///Only returned when the payment request is created, not on polling
    let sessionTokenRequestId: String?

    enum CodingKeys: String, CodingKey {
        case paymentTokenId = "payment_token_id"
        case businessId = "business_id"
        case customerId = "customer_id"
        case country
        case referenceId = "reference_id"
        case currency, status, actions
        case failureCode = "failure_code"
        case created, updated
        case channelCode = "channel_code"
        case sessionTokenRequestId = "session_token_request_id"
    }
}

extension PaymentTokenResponse {
    enum PaymentTokenStatus: String, Codable {
        case requiresAction = "REQUIRES_ACTION"
        case pending = "PENDING"
        case active = "ACTIVE"
        case failed = "FAILED"
        case expired = "EXPIRED"
        case canceled = "CANCELED"
        /// Received when the backend introduces a status not yet known to this SDK version.
        /// Treated as still in-progress (continues polling).
        case unknown

        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            self = Self(rawValue: raw) ?? .unknown
        }
    }

    enum PaymentTokenFailureCode: String, Codable {
        case accountAlreadyLinked = "ACCOUNT_ALREADY_LINKED"
        case invalidAccountDetails = "INVALID_ACCOUNT_DETAILS"
        case authenticationFailed = "AUTHENTICATION_FAILED"
        case cardDeclined = "CARD_DECLINED"
        case captureAmountExceeded = "CAPTURE_AMOUNT_EXCEEDED"
        case insufficientBalance = "INSUFFICIENT_BALANCE"
        case issuerUnavailable = "ISSUER_UNAVAILABLE"
        case channelUnavailable = "CHANNEL_UNAVAILABLE"
        case invalidMerchantSettings = "INVALID_MERCHANT_SETTINGS"
        /// Received when the backend introduces a failure code not yet known to this SDK version.
        case unknown

        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            self = Self(rawValue: raw) ?? .unknown
        }
    }
}
