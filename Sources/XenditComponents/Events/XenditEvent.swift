//
//  XenditEvent.swift
//  XenditComponents
//
//  Created by Ahmad X on 03/05/2026.
//

import Foundation

enum XenditEvent {
    /// Fired when the session is loaded and the SDK is ready.
    case initialized

    /// Fired when the SDK is ready to submit (a channel is selected and form is valid).
    case submissionReady(channelCode: String)

    /// Fired when the SDK is not ready to submit.
    case submissionNotReady

    /// Fired after submission begins.
    case submissionBegin

    /// Fired when a submission completes or fails.
    case submissionEnd(SubmissionEndPayload)

    /// Fired when an action is required after submission.
    case actionBegin

    /// Fired when an action ends (success or failure).
    case actionEnd

    /// Fired when the session is complete (payment processed or token created).
    case sessionComplete

    /// Fired when the session has been canceled or was already completed.
    case sessionCanceled

    /// Fired when the session has expired before the user could complete payment.
    case sessionExpired

    /// Fired when a payment request is created.
    case paymentRequestCreated(paymentRequestId: String)

    /// Fired when a payment request is discarded.
    case paymentRequestDiscarded(paymentRequestId: String)

    /// Fired when a payment token is created.
    case paymentTokenCreated(paymentTokenId: String)

    /// Fired when a payment token is discarded.
    case paymentTokenDiscarded(paymentTokenId: String)

    /// Fired when the SDK encounters an unrecoverable error.
    case fatalError(message: String)

    struct SubmissionEndPayload {
        public let reason: String
        public let userErrorMessages: [String]
        public let developerError: DeveloperError

        public struct DeveloperError {
            public let type: ErrorType
            public let code: String

            public enum ErrorType {
                case networkError
                case error
                case failure
            }
        }
    }
}

/// Typealias for event listeners.
typealias XenditEventListener = (XenditEvent) -> Void
