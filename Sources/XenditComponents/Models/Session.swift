//
//  Session.swift
//  XenditComponents
//
//  Created by Ahmad X on 28/04/2026.
//

import Foundation

/// Represents a Xendit payment session.
public struct Session {
    /// Session ID with prefix `ps-`.
    public let id: String

    /// Description provided by merchant on session creation.
    public let description: String?

    /// The type of session: PAY creates a payment request, SAVE creates a payment token.
    public let sessionType: SessionType

    /// The kind of session. Only COMPONENT sessions can be used with the components SDK.
    public let mode: Mode

    /// Merchant-provided identifier for the session.
    public let referenceId: String

    /// ISO 3166-1 alpha-2 country code.
    public let country: String

    /// ISO 4217 currency code.
    public let currency: String

    /// Amount to be collected (0 for SAVE sessions).
    public let amount: Decimal

    /// When the session will expire.
    public let expiresAt: Date

    /// Locale code for the session.
    public let locale: String

    /// Current session status.
    public let status: Status

    /// Whether the customer is allowed to save their payment method.
    public let allowSavePaymentMethod: AllowSavePaymentMethod?

    /// Whether payment is captured automatically or manually.
    public let captureMethod: CaptureMethod?

    /// Line items associated with the session.
    public let items: [Item]?

    public enum SessionType: Equatable {
        case pay
        case save
    }

    public enum Mode: Equatable {
        case components
    }

    public enum Status: Equatable {
        case active
        case pending
        case canceled
        case expired
        case completed
    }

    public enum AllowSavePaymentMethod: Equatable {
        case disabled
        case optional
        case forced
    }

    public enum CaptureMethod: Equatable {
        case automatic
        case manual
    }

    public struct Item {
        public let type: String
        public let referenceId: String?
        public let name: String
        public let netUnitAmount: Double
        public let quantity: Int
        public let url: String?
        public let imageUrl: String?
        public let category: String?
        public let subcategory: String?
        public let description: String?
        public let metadata: [String: String]?
    }
}
