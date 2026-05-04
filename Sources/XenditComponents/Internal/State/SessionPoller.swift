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
    case paymentRequestFailed(id: String, failureCode: String?)
    case paymentTokenCreated(id: String)
    case paymentTokenFailed(id: String, failureCode: String?)
    case continuePolling
}

// MARK: - Session Poller

final class SessionPoller {
    private var cancellables = Set<AnyCancellable>()
    private let delay: TimeInterval = 5.0

    func startPolling(
        checkoutAPI: CheckoutAPI,
        sessionAuthKey: String,
        tokenRequestId: String?,
        onResult: @escaping (PollResult) -> Void
    ) {
        stopPolling()

        poll(
            checkoutAPI: checkoutAPI,
            sessionAuthKey: sessionAuthKey,
            tokenRequestId: tokenRequestId,
            onResult: onResult
        )
    }

    func stopPolling() {
        cancellables.removeAll()
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
                if case .failure = completion {
                    self.poll(checkoutAPI: checkoutAPI, sessionAuthKey: sessionAuthKey, tokenRequestId: tokenRequestId, onResult: onResult)
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
        case .active:
            break
        case .unknown:
            // Unknown session status — continue polling until a known terminal state is reached.
            break
        }

        if let pr = response.paymentRequest {
            switch pr.status {
            case .succeeded, .authorized, .acceptingPayments:
                return .paymentRequestCreated(id: pr.paymentRequestId)
            case .failed, .canceled, .expired:
                return .paymentRequestFailed(id: pr.paymentRequestId, failureCode: pr.failureCode)
            case .requiresAction:
                return .continuePolling
            case .unknown:
                // Unknown payment request status — continue polling.
                return .continuePolling
            }
        }

        if let pt = response.paymentToken {
            switch pt.status {
            case .active:
                return .paymentTokenCreated(id: pt.paymentTokenId)
            case .failed, .canceled, .expired:
                return .paymentTokenFailed(id: pt.paymentTokenId, failureCode: pt.failureCode)
            case .requiresAction, .pending:
                return .continuePolling
            case .unknown:
                // Unknown payment token status — continue polling.
                return .continuePolling
            }
        }

        return .continuePolling
    }
}
