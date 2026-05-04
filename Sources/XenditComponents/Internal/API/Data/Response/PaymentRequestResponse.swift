//
//  PaymentRequestResponse.swift
//  XenditComponents
//
//  Created by Ahmad X on 05/04/2026.
//

import Foundation

struct PaymentRequestResponse: Decodable {
    let paymentRequestId: String
    let country: String?
    let currency: String?
    let businessId: String?
    let referenceId: String?
    let description: String?
    let created: Date?
    let updated: Date?
    let status: PaymentRequestStatus
    let captureMethod: SessionResponse.Session.CaptureMethod?
    let channelCode: String
    let customerId: String?
    let requestAmount: Decimal?
    let type: PaymentResponse.PaymentType?
    let failureCode: String?
    let actions: [PaymentResponse.Action]
    let sessionTokenRequestId: String?

    enum CodingKeys: String, CodingKey {
        case paymentRequestId = "payment_request_id"
        case country, currency
        case businessId = "business_id"
        case referenceId = "reference_id"
        case description, created, updated, status
        case captureMethod = "capture_method"
        case channelCode = "channel_code"
        case customerId = "customer_id"
        case requestAmount = "request_amount"
        case type
        case failureCode = "failure_code"
        case actions
        case sessionTokenRequestId = "session_token_request_id"
    }
}

extension PaymentRequestResponse {
    enum PaymentRequestStatus: String, Decodable {
        case acceptingPayments = "ACCEPTING_PAYMENTS"
        case requiresAction = "REQUIRES_ACTION"
        case authorized = "AUTHORIZED"
        case canceled = "CANCELED"
        case expired = "EXPIRED"
        case succeeded = "SUCCEEDED"
        case failed = "FAILED"
        /// Received when the backend introduces a status not yet known to this SDK version.
        /// Treated as still in-progress (continues polling).
        case unknown

        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            self = Self(rawValue: raw) ?? .unknown
        }
    }
}
