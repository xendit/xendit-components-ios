//
//  XenditComponents+Submission.swift
//  XenditComponents
//
//  Created by Ahmad X on 03/05/2026.
//

import Combine
import Foundation

// MARK: - Payment submission

extension XenditComponents {

    func performSubmission(
        channel: SessionResponse.Channel,
        session: Session,
        parsedKey: ParsedSdkKey
    ) -> AnyPublisher<SubmissionResult, Error> {
        let channelCode = channel.channelCode
        let properties: [String: Any]
        do {
            properties = try XenditMapper.mapFormValues(
                formValues: stateStore.channelProperties,
                fields: channel.form,
                publicKey: parsedKey.publicKey,
                sessionId: session.id
            )
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }

        switch session.sessionType {
        case .pay:
            let savePaymentMethod: Bool? = (session.allowSavePaymentMethod == .optional && channel.allowSave)
                ? stateStore.savePaymentMethod
                : nil
            let query = PaymentRequestQuery(
                sessionId: parsedKey.sessionAuthKey,
                channelCode: channelCode,
                channelProperties: properties,
                customer: nil,
                savePaymentMethod: savePaymentMethod
            )
            return checkoutAPI.createPaymentRequest(query: query)
                .map { SubmissionResult.paymentRequest($0) }
                .mapError { $0 as Error }
                .eraseToAnyPublisher()

        case .save:
            let query = PaymentTokenQuery(
                sessionId: parsedKey.sessionAuthKey,
                channelCode: channelCode,
                channelProperties: properties
            )
            return checkoutAPI.createPaymentToken(query: query)
                .map { SubmissionResult.paymentToken($0) }
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
    }

    func handleSubmissionResult(
        _ result: SubmissionResult,
        parsedKey: ParsedSdkKey
    ) -> AnyPublisher<Void, Error> {
        let tokenRequestId: String?
        let actions: [PaymentResponse.Action]

        switch result {
        case .paymentRequest(let pr):
            dispatch(.paymentRequestCreated(paymentRequestId: pr.paymentRequestId))
            tokenRequestId = pr.sessionTokenRequestId
            actions = pr.actions
            switch pr.status {
            case .succeeded, .authorized, .acceptingPayments, .failed, .canceled, .expired:
                return handleFinalPaymentRequestStatus(pr)
            case .requiresAction:
                handleRequiresAction(actions)
            case .unknown:
                break
            }

        case .paymentToken(let pt):
            dispatch(.paymentTokenCreated(paymentTokenId: pt.paymentTokenId))
            tokenRequestId = pt.sessionTokenRequestId
            actions = pt.actions
            switch pt.status {
            case .active:
                stateStore.isSubmitting = false
                dispatch(.sessionComplete)
                return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
            case .requiresAction, .pending:
                handleRequiresAction(actions)
            case .failed, .canceled, .expired:
                stateStore.isSubmitting = false
                let strings = XenditStrings(locale: stateStore.session?.locale ?? "en")
                dispatch(.submissionEnd(.init(
                    reason: "PAYMENT_TOKEN_\(pt.status)",
                    userErrorMessages: [
                        strings.string(forKey: "payment_token_status.failed.title"),
                        strings.string(forKey: "payment_token_status.failed.subtext")
                    ],
                    developerError: .init(type: .failure, code: pt.failureCode ?? "UNKNOWN")
                )))
                return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
            case .unknown:
                break
            }
        }

        return startPolling(parsedKey: parsedKey, tokenRequestId: tokenRequestId)
    }

    private func handleRequiresAction(_ actions: [PaymentResponse.Action]) {
        let action = actions.first(where: {
            if case .redirectCustomer = $0 { return true }
            if case .presentToCustomer(let d) = $0 { return !d.value.isEmpty }
            return false
        })
        guard let action, let paymentAction = PaymentAction.from(action) else { return }
        stateStore.activeAction = paymentAction
        dispatch(.actionBegin)
    }

    private func handleFinalPaymentRequestStatus(_ pr: PaymentRequestResponse) -> AnyPublisher<Void, Error> {
        stateStore.isSubmitting = false
        let strings = XenditStrings(locale: stateStore.session?.locale ?? "en")

        switch pr.status {
        case .succeeded, .authorized, .acceptingPayments:
            dispatch(.sessionComplete)

        case .failed:
            let message = pr.failureCode.map { strings.failureMessage(forCode: $0) }
                ?? strings.string(forKey: "payment_request_status.failed.subtext")
            dispatch(.submissionEnd(.init(
                reason: "PAYMENT_REQUEST_FAILED",
                userErrorMessages: [strings.string(forKey: "payment_request_status.failed.title"), message],
                developerError: .init(type: .failure, code: pr.failureCode ?? "UNKNOWN")
            )))

        case .canceled:
            dispatch(.submissionEnd(.init(
                reason: "PAYMENT_REQUEST_CANCELED",
                userErrorMessages: [
                    strings.string(forKey: "payment_request_status.canceled.title"),
                    strings.string(forKey: "payment_request_status.canceled.subtext")
                ],
                developerError: .init(type: .failure, code: "PAYMENT_REQUEST_CANCELED")
            )))

        case .expired:
            dispatch(.submissionEnd(.init(
                reason: "PAYMENT_REQUEST_EXPIRED",
                userErrorMessages: [
                    strings.string(forKey: "payment_request_status.expired.title"),
                    strings.string(forKey: "payment_request_status.expired.subtext")
                ],
                developerError: .init(type: .failure, code: "PAYMENT_REQUEST_EXPIRED")
            )))

        case .requiresAction, .unknown:
            break
        }

        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    // MARK: - Polling

    private func startPolling(
        parsedKey: ParsedSdkKey,
        tokenRequestId: String?
    ) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self else {
                promise(.failure(URLError(.cancelled)))
                return
            }
            self.poller.startPolling(
                checkoutAPI: self.checkoutAPI,
                sessionAuthKey: parsedKey.sessionAuthKey,
                tokenRequestId: tokenRequestId
            ) { result in
                self.handlePollResult(result)
                if case .continuePolling = result { return }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    private func handlePollResult(_ result: PollResult) {
        dispatch(.actionEnd)
        let locale = stateStore.session?.locale ?? "en"
        let strings = XenditStrings(locale: locale)

        switch result {
        case .sessionComplete:
            dispatch(.sessionComplete)
        case .sessionExpired:
            dispatch(.sessionExpired)
        case .sessionCanceled:
            dispatch(.sessionCanceled)
        case .paymentRequestCreated:
            dispatch(.sessionComplete)

        case .paymentRequestFailed(_, let failureCode):
            let message = failureCode.map { strings.failureMessage(forCode: $0) }
                ?? strings.string(forKey: "payment_request_status.failed.subtext")
            dispatch(.submissionEnd(.init(
                reason: "PAYMENT_REQUEST_FAILED",
                userErrorMessages: [strings.string(forKey: "payment_request_status.failed.title"), message],
                developerError: .init(type: .failure, code: failureCode ?? "UNKNOWN")
            )))

        case .paymentTokenCreated:
            dispatch(.sessionComplete)

        case .paymentTokenFailed(_, let failureCode):
            dispatch(.submissionEnd(.init(
                reason: "PAYMENT_TOKEN_FAILED",
                userErrorMessages: [
                    strings.string(forKey: "payment_token_status.failed.title"),
                    strings.string(forKey: "payment_token_status.failed.subtext")
                ],
                developerError: .init(type: .failure, code: failureCode ?? "UNKNOWN")
            )))

        case .continuePolling:
            break
        }
    }
}

// MARK: - SubmissionResult

enum SubmissionResult {
    case paymentRequest(PaymentRequestResponse)
    case paymentToken(PaymentTokenResponse)
}
