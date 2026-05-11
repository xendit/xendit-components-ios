//
//  XDTPaymentResult.swift
//  XenditComponents
//
//  Created by Ahmad X on 03/05/2026.
//

import Foundation

// MARK: - XDTPaymentStatus

/// Objective-C compatible status codes for a Xendit payment outcome.
@objc(XDTPaymentStatus)
public enum XDTPaymentStatus: Int {
    /// Payment or token was successfully created.
    case success   = 0
    /// The payment failed. Inspect `XDTPaymentResult.error` for details.
    case failed    = 1
    /// The session was terminated by the API (e.g. canceled externally).
    case canceled  = 2
    /// The session expired before the user completed payment.
    case expired   = 3
    /// The user closed the payment sheet without completing.
    case dismissed = 4
}

// MARK: - XDTPaymentResult

/// Objective-C compatible representation of a Xendit payment outcome.
///
/// Check `status` first, then read the associated properties for that status:
/// - `.success`   → `paymentRequestId`, `channelCode`
/// - `.failed`    → `error`
/// - `.canceled`, `.expired`, `.dismissed` → no additional data
///
/// ```objc
/// [XDTComponents presentFromViewController:self
///                        componentsSdkKey:key
///                                onResult:^(XDTPaymentResult *r) {
///     switch (r.status) {
///         case XDTPaymentStatusSuccess:
///             NSLog(@"ID: %@  Channel: %@", r.paymentRequestId, r.channelCode);
///             break;
///         case XDTPaymentStatusFailed:
///             NSLog(@"[%@] %@", r.error.xenditCode, r.error.message);
///             break;
///         case XDTPaymentStatusCanceled:
///             NSLog(@"Canceled.");
///             break;
///         case XDTPaymentStatusExpired:
///             NSLog(@"Expired.");
///             break;
///         case XDTPaymentStatusDismissed:
///             NSLog(@"User dismissed.");
///             break;
///     }
/// }];
/// ```
@objc(XDTPaymentResult)
public final class XDTPaymentResult: NSObject {

    // MARK: - Properties

    /// The outcome status. Always inspect this before reading associated properties.
    @objc public let status: XDTPaymentStatus

    /// The payment request or token identifier. Non-empty only when `status == .success`.
    @objc public let paymentRequestId: String

    /// The payment channel code used (e.g. `"CARDS"`). Non-empty only when `status == .success`.
    @objc public let channelCode: String

    /// Failure details. Non-nil only when `status == .failed`.
    @objc public let error: XDTError?

    // MARK: - Internal init (Swift → ObjC bridge)

    init(swiftResult: XenditPaymentResult) {
        switch swiftResult {
        case .success(let id, let code):
            status           = .success
            paymentRequestId = id
            channelCode      = code
            error            = nil
        case .failed(let xenditError):
            status           = .failed
            paymentRequestId = ""
            channelCode      = ""
            error            = XDTError(swiftError: xenditError)
        case .canceled:
            status           = .canceled
            paymentRequestId = ""
            channelCode      = ""
            error            = nil
        case .expired:
            status           = .expired
            paymentRequestId = ""
            channelCode      = ""
            error            = nil
        case .dismissed:
            status           = .dismissed
            paymentRequestId = ""
            channelCode      = ""
            error            = nil
        }
        super.init()
    }

    // MARK: - Debug

    override public var description: String {
        switch status {
        case .success:   return "XDTPaymentResult(success, id: \(paymentRequestId), channel: \(channelCode))"
        case .failed:    return "XDTPaymentResult(failed, code: \(error?.xenditCode ?? "?"))"
        case .canceled:  return "XDTPaymentResult(canceled)"
        case .expired:   return "XDTPaymentResult(expired)"
        case .dismissed: return "XDTPaymentResult(dismissed)"
        @unknown default: return "XDTPaymentResult(unknown)"
        }
    }
}

// MARK: - XDTError

/// Objective-C compatible representation of a Xendit payment error.
@objc(XDTError)
public final class XDTError: NSObject {

    // MARK: - Properties

    /// Machine-readable error code (e.g. `"INSUFFICIENT_FUNDS"`, `"CARD_DECLINED"`).
    @objc public let xenditCode: String

    /// Localized, user-safe error message suitable for display.
    @objc public let message: String

    // MARK: - Init

    /// Creates an `XDTError` — useful for unit tests or mocking.
    @objc public init(code: String, message: String) {
        self.xenditCode = code
        self.message    = message
        super.init()
    }

    // Swift-only — not exposed to ObjC (takes a non-bridgeable Swift type)
    convenience init(swiftError: XenditError) {
        self.init(code: swiftError.code, message: swiftError.message)
    }

    // MARK: - Debug

    override public var description: String {
        "XDTError(code: \(xenditCode), message: \(message))"
    }
}
