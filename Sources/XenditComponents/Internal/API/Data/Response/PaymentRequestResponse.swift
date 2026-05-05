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
    let failureCode: PaymentRequestFailureCode?
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
    
    enum PaymentRequestFailureCode: String, Codable {
        case accountAccessBlocked = "ACCOUNT_ACCESS_BLOCKED"
        case invalidMerchantSettings = "INVALID_MERCHANT_SETTINGS"
        case invalidAccountDetails = "INVALID_ACCOUNT_DETAILS"
        case paymentAttemptCountsExceeded = "PAYMENT_ATTEMPT_COUNTS_EXCEEDED"
        case userDeviceUnreachable = "USER_DEVICE_UNREACHABLE"
        case channelUnavailable = "CHANNEL_UNAVAILABLE"
        case insufficientBalance = "INSUFFICIENT_BALANCE"
        case accountNotActivated = "ACCOUNT_NOT_ACTIVATED"
        case invalidToken = "INVALID_TOKEN"
        case serverError = "SERVER_ERROR"
        case partnerTimeoutError = "PARTNER_TIMEOUT_ERROR"
        case timeoutError = "TIMEOUT_ERROR"
        case userDeclinedPayment = "USER_DECLINED_PAYMENT"
        case userDidNotAuthorize = "USER_DID_NOT_AUTHORIZE"
        case paymentRequestExpired = "PAYMENT_REQUEST_EXPIRED"
        case failureDetailsUnavailable = "FAILURE_DETAILS_UNAVAILABLE"
        case expiredOtp = "EXPIRED_OTP"
        case invalidOtp = "INVALID_OTP"
        case paymentAmountLimitsExceeded = "PAYMENT_AMOUNT_LIMITS_EXCEEDED"
        case otpAttemptCountsExceeded = "OTP_ATTEMPT_COUNTS_EXCEEDED"
        case cardDeclined = "CARD_DECLINED"
        case declinedByIssuer = "DECLINED_BY_ISSUER"
        case issuerUnavailable = "ISSUER_UNAVAILABLE"
        case invalidCvv = "INVALID_CVV"
        case declinedByProcessor = "DECLINED_BY_PROCESSOR"
        case captureAmountExceeded = "CAPTURE_AMOUNT_EXCEEDED"
        case authenticationFailed = "AUTHENTICATION_FAILED"
        case expiredCard = "EXPIRED_CARD"
        case suspectedFradulent = "SUSPECTED_FRAUDULENT"
        case stolenCard = "STOLEN_CARD"
        case inactiveOrUnauthorizedCard = "INACTIVE_OR_UNAUTHORIZED_CARD"
        case processorError = "PROCESSOR_ERROR"

        /// Received when the backend introduces a failure code not yet known to this SDK version.
        case unknown

        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            self = Self(rawValue: raw) ?? .unknown
        }
    }
}
    