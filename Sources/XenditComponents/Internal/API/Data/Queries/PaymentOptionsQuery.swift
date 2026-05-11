//
//  PaymentOptionsQuery.swift
//  XenditComponents
//
//  Created by Ahmad X on 05/04/2026.
//

import Foundation

struct PaymentOptionsQuery {
    let channelCode: String
    let channelProperties: [String: Any]?
    
    var json: [String: Any] {
        var json: [String: Any?] = [
            "channel_code": channelCode,
            "channel_properties": channelProperties
        ]
        
        return json.compactMapValues { $0 }
    }

    init(channelCode: String, channelProperties: [String : Any]? = nil) {
        self.channelCode = channelCode
        self.channelProperties = channelProperties
    }
}
