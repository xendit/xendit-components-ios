//
//  SessionResponse+Session.swift
//  XenditComponents
//
//  Created by Ahmad X on 04/04/2026.
//

import Foundation

extension SessionResponse {
    struct Session: Decodable {
        let paymentSessionId: String
        let created: Date
        let updated: Date
        let status: SessionStatus
        let referenceId: String
        let currency: String
        let amount: Decimal
        let country: String
        let expiresAt: Date
        let sessionType: SessionType
        let mode: SessionMode
        let locale: String
        let businessId: String?
        let customerId: String?
        let captureMethod: CaptureMethod?
        let description: String?
        let items: [Item]?
        let allowSavePaymentMethod: AllowSavePaymentMethod?
        let componentsSdkKey: String?
        let componentsConfiguration: ComponentsConfiguration
        let subscription: Subscription?

        enum CodingKeys: String, CodingKey {
            case paymentSessionId = "payment_session_id"
            case created, updated
            case status
            case referenceId = "reference_id"
            case currency, amount, country
            case expiresAt = "expires_at"
            case sessionType = "session_type"
            case mode, locale
            case businessId = "business_id"
            case customerId = "customer_id"
            case captureMethod = "capture_method"
            case description, items
            case allowSavePaymentMethod = "allow_save_payment_method"
            case componentsSdkKey = "components_sdk_key"
            case componentsConfiguration = "components_configuration"
            case subscription
        }
    }
}


extension SessionResponse.Session {
    enum SessionType: String, Decodable {
        case pay = "PAY"
        case save = "SAVE"
        case subscription = "SUBSCRIPTION"
        case authorization = "AUTHORIZATION"
        /// Received when the backend introduces a session type not yet known to this SDK version.
        case unknown

        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            self = Self(rawValue: raw) ?? .unknown
        }
    }

    enum SessionMode: String, Decodable {
        case paymentLink = "PAYMENT_LINK"
        case components = "COMPONENTS"
        case cardsSessionJs = "CARDS_SESSION_JS"
        /// Received when the backend introduces a mode not yet known to this SDK version.
        case unknown

        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            self = Self(rawValue: raw) ?? .unknown
        }
    }

    enum SessionStatus: String, Decodable {
        case active = "ACTIVE"
        case completed = "COMPLETED"
        case expired = "EXPIRED"
        case canceled = "CANCELED"
        case pending = "PENDING"
        /// Received when the backend introduces a status not yet known to this SDK version.
        case unknown

        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            self = Self(rawValue: raw) ?? .unknown
        }
    }

    enum AllowSavePaymentMethod: String, Decodable {
        case disabled = "DISABLED"
        case forced = "FORCED"
        case optional = "OPTIONAL"
        /// Received when the backend introduces a value not yet known to this SDK version.
        /// Treated as `.disabled` for safety.
        case unknown

        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            self = Self(rawValue: raw) ?? .unknown
        }
    }

    enum CaptureMethod: String, Decodable {
        case automatic = "AUTOMATIC"
        case manual = "MANUAL"
        /// Received when the backend introduces a capture method not yet known to this SDK version.
        /// Treated as `.automatic` for safety.
        case unknown

        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            self = Self(rawValue: raw) ?? .unknown
        }
    }

}

// MARK: - Item

extension SessionResponse.Session {
    struct Item: Decodable {
        let referenceId: String?
        let type: ItemType
        let name: String
        let netUnitAmount: Decimal
        let quantity: Int
        let category: String?
        let url: String?
        let imageUrl: String?
        let subcategory: String?
        let description: String?
        let metadata: [String: String]?

        enum CodingKeys: String, CodingKey {
            case referenceId = "reference_id"
            case type, name
            case netUnitAmount = "net_unit_amount"
            case quantity, category, url
            case imageUrl = "image_url"
            case subcategory, description, metadata
        }
    }

    enum ItemType: String, Codable {
        case digitalProduct = "DIGITAL_PRODUCT"
        case physicalProduct = "PHYSICAL_PRODUCT"
        case digitalService = "DIGITAL_SERVICE"
        case physicalService = "PHYSICAL_SERVICE"
        case fee = "FEE"
        /// Received when the backend introduces an item type not yet known to this SDK version.
        case unknown

        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            self = Self(rawValue: raw) ?? .unknown
        }
    }
}

// MARK: - Subscription

extension SessionResponse.Session {
    enum Interval: String, Codable {
            case day = "DAY"
            case week = "WEEK"
            case month = "MONTH"
        }

    struct Subscription: Decodable {
        let immediatePayment: Bool?
        let schedule: Schedule?

        enum CodingKeys: String, CodingKey {
            case immediatePayment = "immediate_payment"
            case schedule
        }

        struct Schedule: Decodable {
            let anchorDate: String
            let interval: Interval
            let intervalCount: Int
            let retryInterval: Interval?
            let retryIntervalCount: Int?
            let totalRecurrence: Int?
            let totalRetry: Int?

            enum CodingKeys: String, CodingKey {
                case anchorDate = "anchor_date"
                case interval
                case intervalCount = "interval_count"
                case retryInterval = "retry_interval"
                case retryIntervalCount = "retry_interval_count"
                case totalRecurrence = "total_recurrence"
                case totalRetry = "total_retry"
            }
        }
    }
}

// MARK: - Components Configuration

extension SessionResponse.Session {
    struct ComponentsConfiguration: Decodable {
        let origins: [String]
    }
}

// MARK: - Mapping

extension SessionResponse.Session {
    func toModel() -> Session {
        Session(
            id: paymentSessionId,
            description: description,
            sessionType: sessionType.toModel(),
            mode: .components,
            referenceId: referenceId,
            country: country,
            currency: currency,
            amount: amount,
            expiresAt: expiresAt,
            locale: locale,
            status: status.toModel(),
            allowSavePaymentMethod: allowSavePaymentMethod.map { $0.toModel() },
            captureMethod: captureMethod == .manual ? .manual : .automatic,
            items: items?.map { $0.toModel() },
            subscription: subscription?.toModel()
        )
    }
}

extension SessionResponse.Session.SessionType {
    init(_ publicType: Session.SessionType) {
        switch publicType {
        case .pay: self = .pay
        case .subscription: self = .subscription
        case .save, .unknown: self = .save
        }
    }
}

private extension SessionResponse.Session.SessionType {
    func toModel() -> Session.SessionType {
        switch self {
        case .pay: return .pay
        case .subscription: return .subscription
        case .save, .authorization, .unknown: return .save
        }
    }
}

private extension SessionResponse.Session.Subscription {
    func toModel() -> Session.Subscription {
        Session.Subscription(
            immediatePayment: immediatePayment,
            schedule: schedule.map {
                Session.Subscription.Schedule(
                    anchorDate: $0.anchorDate,
                    interval: $0.interval.toModel(),
                    intervalCount: $0.intervalCount,
                    retryInterval: $0.retryInterval?.toModel(),
                    retryIntervalCount: $0.retryIntervalCount,
                    totalRecurrence: $0.totalRecurrence,
                    totalRetry: $0.totalRetry
                )
            }
        )
    }
}

private extension SessionResponse.Session.Interval {
    func toModel() -> Session.Interval {
        switch self {
        case .day: return .day
        case .week: return .week
        case .month: return .month
        }
    }
}

private extension SessionResponse.Session.SessionStatus {
    func toModel() -> Session.Status {
        switch self {
        case .active: return .active
        case .pending: return .pending
        case .completed: return .completed
        case .expired: return .expired
        case .canceled: return .canceled
        case .unknown: return .active
        }
    }
}

private extension SessionResponse.Session.AllowSavePaymentMethod {
    func toModel() -> Session.AllowSavePaymentMethod {
        switch self {
        case .disabled: return .disabled
        case .optional: return .optional
        case .forced: return .forced
        case .unknown: return .disabled
        }
    }
}

private extension SessionResponse.Session.Item {
    func toModel() -> Session.Item {
        Session.Item(
            type: type.rawValue,
            referenceId: referenceId,
            name: name,
            netUnitAmount: NSDecimalNumber(decimal: netUnitAmount).doubleValue,
            quantity: quantity,
            url: url,
            imageUrl: imageUrl,
            category: category,
            subcategory: subcategory,
            description: description,
            metadata: metadata
        )
    }
}
