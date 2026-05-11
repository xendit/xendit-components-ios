//
//  PaymentTokenQuery.swift
//  XenditComponents
//
//  Created by Ahmad X on 05/04/2026.
//

import Foundation

struct PaymentTokenQuery {
    let sessionId: String
    let channelCode: String
    let channelProperties: [String: Any]?

    var json: [String: Any] {
        var json: [String: Any?] = [
            "session_id": sessionId,
            "channel_code": channelCode,
            "channel_properties": channelProperties
        ]

        return json.compactMapValues { $0 }
    }

    init(sessionId: String, channelCode: String, channelProperties: [String: Any]? = nil) {
        self.sessionId = sessionId
        self.channelCode = channelCode
        self.channelProperties = channelProperties
    }
}
