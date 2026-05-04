//
//  CardInfoResponse.swift
//  XenditComponents
//
//  Created by Ahmad X on 04/04/2026.
//

import Foundation

struct CardInfoResponse: Decodable {
    let requireBillingInformation: Bool
    let countryCodes: [String]
    let schemes: [String]
    
    enum CodingKeys: String, CodingKey {
        case requireBillingInformation = "require_billing_information"
        case countryCodes = "country_codes"
        case schemes
    }
}
