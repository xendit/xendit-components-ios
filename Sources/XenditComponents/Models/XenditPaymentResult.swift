//
//  XenditPaymentResult.swift
//  XenditComponents
//
//  Created by Ahmad X on 28/04/2026.
//

import Foundation

/// Encapsulates the possible outcomes of a Xendit payment session.
public enum XenditPaymentResult {
    /// Payment or token save completed successfully.
    case success(paymentRequestId: String, channelCode: String)
    
    /// Payment failed with a specific error.
    case failed(error: XenditError)
    
    /// Session was terminated via API by merchant backend (Session.status = CANCELED).
    case canceled
    
    /// Session has timed out or reached expiration (Session.status = EXPIRED).
    case expired
    
    /// User manually closed the sheet without completing. Not an error.
    case dismissed
}

/// Represents an error returned by the Xendit Components SDK.
public struct XenditError: Error {
    /// Machine-readable error code, e.g. "INSUFFICIENT_FUNDS".
    public let code: String
    
    /// Localised error message, safe to show the user.
    public let message: String
    
    /// Original network or server error, for logging.
    public let underlyingError: Error?
    
    public init(code: String, message: String, underlyingError: Error? = nil) {
        self.code = code
        self.message = message
        self.underlyingError = underlyingError
    }
}
