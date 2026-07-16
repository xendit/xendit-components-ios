//
//  SessionPoller.swift
//  XenditComponents
//
//  Created by Ahmad X on 03/05/2026.
//

import Combine
import Foundation

// MARK: - Polling Result

enum PollResult {
    case sessionComplete
    case sessionExpired
    case sessionCanceled
    case paymentRequestCreated(id: String)
    case paymentRequestFailed(id: String, failureCode: PaymentRequestResponse.PaymentRequestFailureCode?)
    case paymentTokenCreated(id: String)
    case paymentTokenFailed(id: String, failureCode: PaymentTokenResponse.PaymentTokenFailureCode?)
    case requiresAction
    case pollFailed(errorCode: String, message: String)
    case continuePolling
}

// MARK: - Session Poller

final class SessionPoller {
    private var cancellables = Set<AnyCancellable>()
    private let delay: TimeInterval = 5.0
    private(set) var isPolling = false

    private var lastCheckoutAPI: CheckoutAPI?
    private var lastSessionAuthKey: String?
    private var lastTokenRequestId: String?
    private var lastOnResult: ((PollResult) -> Void)?

    func startPolling(
        checkoutAPI: CheckoutAPI,
        sessionAuthKey: String,
        tokenRequestId: String?,
        onResult: @escaping (PollResult) -> Void
    ) {
        stopPolling()
        lastCheckoutAPI = checkoutAPI
        lastSessionAuthKey = sessionAuthKey
        lastTokenRequestId = tokenRequestId
        lastOnResult = onResult
        isPolling = true

        poll(
            checkoutAPI: checkoutAPI,
            sessionAuthKey: sessionAuthKey,
            tokenRequestId: tokenRequestId,
            onResult: onResult
        )
    }

    func stopPolling() {
        cancellables.removeAll()
        isPolling = false
    }

    func resumePolling() {
        guard !isPolling,
              let api = lastCheckoutAPI,
              let key = lastSessionAuthKey,
              let onResult = lastOnResult else { return }
        isPolling = true
        poll(checkoutAPI: api, sessionAuthKey: key, tokenRequestId: lastTokenRequestId, onResult: onResult)
    }

    private func poll(
        checkoutAPI: CheckoutAPI,
        sessionAuthKey: String,
        tokenRequestId: String?,
        onResult: @escaping (PollResult) -> Void
    ) {
        checkoutAPI.pollSession(sessionAuthKey: sessionAuthKey, tokenRequestId: tokenRequestId)
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    let errorCode = error.errorCode
                    let message = error.backendError?.message ?? "An unexpected error occurred"
                    onResult(.pollFailed(errorCode: errorCode, message: message))
                    self.stopPolling()
                }
            }, receiveValue: { [weak self] response in
                guard let self else { return }
                let result = self.interpretPollResponse(response)
                onResult(result)

                switch result {
                case .continuePolling:
                    self.poll(checkoutAPI: checkoutAPI, sessionAuthKey: sessionAuthKey, tokenRequestId: tokenRequestId, onResult: onResult)
                default:
                    self.stopPolling()
                }
            })
            .store(in: &cancellables)
    }

    private func interpretPollResponse(_ response: PollResponse) -> PollResult {
        switch response.session.status {
        case .completed:
            return .sessionComplete
        case .expired:
            return .sessionExpired
        case .canceled:
            return .sessionCanceled
        case .active, .pending, .unknown:
            break
        }

        if let pr = response.paymentRequest {
            switch pr.status {
            case .succeeded, .authorized, .acceptingPayments:
                return .paymentRequestCreated(id: pr.paymentRequestId)
            case .failed, .canceled, .expired:
                return .paymentRequestFailed(id: pr.paymentRequestId, failureCode: pr.failureCode)
            case .unknown:
                return .requiresAction
            case .requiresAction, .pending:
                break
            }
        }

        if let pt = response.paymentToken {
            switch pt.status {
            case .active:
                return .paymentTokenCreated(id: pt.paymentTokenId)
            case .failed, .canceled, .expired:
                return .paymentTokenFailed(id: pt.paymentTokenId, failureCode: pt.failureCode)
            case .unknown:
                return .requiresAction
            case .requiresAction, .pending:
                break
            }
        }

        return .continuePolling
    }
}
