//
//  PollResponse.swift
//  XenditComponents
//
//  Created by Ahmad X on 04/04/2026.
//

import Foundation

struct PollResponse: Decodable {
    let session: SessionResponse.Session
    let paymentToken: PaymentTokenResponse?
    let paymentRequest: PaymentRequestResponse?
    let succeededChannel: SucceededChannel?
    let errorContent: ErrorContent?

    enum CodingKeys: String, CodingKey {
        case session
        case paymentToken = "payment_token"
        case paymentRequest = "payment_request"
        case succeededChannel = "succeeded_channel"
        case errorContent = "error_content"
    }

}

extension PollResponse {
    struct SucceededChannel: Decodable {
        let channelCode: String
        let logoUrl: String

        enum CodingKeys: String, CodingKey {
            case channelCode = "channel_code"
            case logoUrl = "logo_url"
        }
    }

    struct ErrorContent: Decodable {
        let title: String
        let message1: String
        let message2: String?

        enum CodingKeys: String, CodingKey {
            case title
            case message1 = "message_1"
            case message2 = "message_2"
        }
    }
}
