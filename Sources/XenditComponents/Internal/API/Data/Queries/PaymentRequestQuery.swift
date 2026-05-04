//
//  PaymentRequestQuery.swift
//  XenditComponents
//
//  Created by Ahmad X on 05/04/2026.
//

import Foundation

struct PaymentRequestQuery {
    let sessionId: String
    let channelCode: String
    let channelProperties: [String: Any]
    
    let customer: SessionResponse.Customer?
    let savePaymentMethod: Bool?
    
    var json: [String: Any] {
        var json: [String: Any?] = [
            "session_id": sessionId,
            "channel_code": channelCode,
            "channel_properties": channelProperties,
            "customer": customer?.toDictionary(),
            "save_payment_method": savePaymentMethod
        ]
        
        return json.compactMapValues { $0 }
    }
    
    init(
        sessionId: String,
        channelCode: String,
        channelProperties: [String: Any],
        customer: SessionResponse.Customer? = nil,
        savePaymentMethod: Bool? = nil
    ) {
        self.sessionId = sessionId
        self.channelCode = channelCode
        self.channelProperties = channelProperties
        self.customer = customer
        self.savePaymentMethod = savePaymentMethod
    }
}

