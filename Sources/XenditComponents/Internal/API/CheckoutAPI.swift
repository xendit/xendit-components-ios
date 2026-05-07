//
//  CheckoutAPI.swift
//  XenditComponents
//
//  Created by Ahmad X on 08/04/2026.
//

import Combine
import Foundation

final class CheckoutAPI {
    private let client = APIClient.shared
    private let sdkVersion = XenditComponents.sdkVersion

    init() {}

    func fetchSession(sessionAuthKey: String) -> AnyPublisher<SessionResponse.Response, APIClientError> {
        client.get(
            .path("/api/sessions/\(sessionAuthKey)"),
            queries: ["components_version": sdkVersion],
            headers: [.custom("origin", "https://demo-store.xendit.co")] //TODO: Should not hardcoded
        )
    }

    func createPaymentRequest(query: PaymentRequestQuery) -> AnyPublisher<PaymentRequestResponse, APIClientError> {
        client.post(
            .path("/api/sessions/payment_requests?components_version=\(sdkVersion)"),
            json: query.json,
            headers: [.custom("origin", "https://demo-store.xendit.co")]
        )
    }

    func createPaymentToken(query: PaymentTokenQuery) -> AnyPublisher<PaymentTokenResponse, APIClientError> {
        client.post(
            .path("/api/sessions/payment_tokens?components_version=\(sdkVersion)"),
            json: query.json,
            headers: [.custom("origin", "https://demo-store.xendit.co")]
        )
    }

    func pollSession(sessionAuthKey: String, tokenRequestId: String? = nil) -> AnyPublisher<PollResponse, APIClientError> {
        var queries: [String: Any] = [:]
        if let tokenRequestId = tokenRequestId {
            queries["token_request_id"] = tokenRequestId
        }
        queries["components_version"] = sdkVersion

        return client.get(
            .path("/api/sessions/\(sessionAuthKey)/poll"),
            queries: queries,
            headers: [.custom("origin", "https://demo-store.xendit.co")]
        )
    }

    func getCardInfo(sessionAuthKey: String, query: CardInfoQuery) -> AnyPublisher<CardInfoResponse, APIClientError> {
        client.post(
            .path("/api/sessions/\(sessionAuthKey)/card_info?components_version=\(sdkVersion)"),
            json: query.json,
            headers: [.custom("origin", "https://demo-store.xendit.co")]
        )
    }

    //NOTE: Fetch this when full PAN only
    func getPaymentOptions(sessionAuthKey: String, query: PaymentOptionsQuery) -> AnyPublisher<PaymentOptionsResponse, APIClientError> {
        client.post(
            .path("/api/sessions/\(sessionAuthKey)/payment_options?components_version=\(sdkVersion)"),
            json: query.json,
            headers: [.custom("origin", "https://demo-store.xendit.co")]
        )
    }
}
