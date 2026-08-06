//
//  Session.swift
//  XenditComponents
//
//  Created by Ahmad X on 28/04/2026.
//

import Foundation

/// Represents a Xendit payment session.
struct Session {
    let id: String
    let description: String?
    let sessionType: SessionType
    let mode: Mode
    let referenceId: String
    let country: String
    let currency: String
    let amount: Decimal
    let expiresAt: Date
    let locale: String
    let status: Status
    let allowSavePaymentMethod: AllowSavePaymentMethod?
    let captureMethod: CaptureMethod?
    let items: [Item]?
    let subscription: Subscription?

    enum SessionType: Equatable {
        case pay
        case save
        case subscription
        case unknown
    }

    enum Mode: Equatable {
        case components
    }

    enum Status: Equatable {
        case active
        case pending
        case canceled
        case expired
        case completed
    }

    enum AllowSavePaymentMethod: Equatable {
        case disabled
        case optional
        case forced
    }

    enum CaptureMethod: Equatable {
        case automatic
        case manual
    }

    struct Item {
        let type: String
        let referenceId: String?
        let name: String
        let netUnitAmount: Double
        let quantity: Int
        let url: String?
        let imageUrl: String?
        let category: String?
        let subcategory: String?
        let description: String?
        let metadata: [String: String]?
    }

    struct Subscription {
        let immediatePayment: Bool?
        let schedule: Schedule?

        struct Schedule {
            let anchorDate: String
            let interval: String
            let intervalCount: Int
            let retryInterval: String?
            let retryIntervalCount: Int?
            let totalRecurrence: Int?
            let totalRetry: Int?
        }
    }
}
