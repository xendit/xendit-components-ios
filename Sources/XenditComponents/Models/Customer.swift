//
//  Customer.swift
//  XenditComponents
//
//  Created by Ahmad X on 28/04/2026.
//

import Foundation

/// Represents the customer associated with a payment session.
public struct Customer {
    public let id: String
    public let type: CustomerType
    public let email: String?
    public let mobileNumber: String?
    public let individualDetail: IndividualDetail?

    public enum CustomerType {
        case individual
    }

    public struct IndividualDetail {
        public let givenNames: String
        public let surname: String?
    }
}
