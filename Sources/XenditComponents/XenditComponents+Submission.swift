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

        case .save, .subscription:
            let query = PaymentTokenQuery(
                sessionId: parsedKey.sessionAuthKey,
                channelCode: channelCode,
                channelProperties: properties
            )
            return checkoutAPI.createPaymentToken(query: query)
                .map { SubmissionResult.paymentToken($0) }
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
            
        default:
            return Fail(error: URLError(.unsupportedURL)).eraseToAnyPublisher()
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
            lastPaymentRequestId = pr.paymentRequestId
            tokenRequestId = pr.sessionTokenRequestId
            actions = pr.actions
            switch pr.status {
            case .succeeded, .authorized, .acceptingPayments, .failed, .canceled, .expired:
                return handleFinalPaymentRequestStatus(pr)
            case .requiresAction:
                handleRequiresAction(actions)
            case .pending, .unknown:
                break
            }

        case .paymentToken(let pt):
            dispatch(.paymentTokenCreated(paymentTokenId: pt.paymentTokenId))
            tokenRequestId = pt.sessionTokenRequestId
            actions = pt.actions
            switch pt.status {
            case .active, .failed, .canceled, .expired:
                return handleFinalPaymentTokenStatus(pt)
            case .requiresAction, .pending:
                handleRequiresAction(actions)
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
        if let action, let paymentAction = PaymentAction.from(action) {
            if paymentAction.isDeeplink, let url = URL(string: paymentAction.value) {
                stateStore.pendingDeeplinkUrl = url
            } else {
                stateStore.activeAction = paymentAction
            }
            dispatch(.actionBegin)
        } else {
            stateStore.awaitingPaymentAction = .emptyPaymentActions
        }
    }

    private func handleFinalPaymentRequestStatus(_ pr: PaymentRequestResponse) -> AnyPublisher<Void, Error> {
        stateStore.isSubmitting = false
        let strings = XenditStrings(locale: stateStore.session?.locale ?? "en")

        switch pr.status {
        case .succeeded, .authorized, .acceptingPayments:
            dispatch(.sessionComplete)

        case .failed:
            let message = pr.failureCode.flatMap { strings.failureMessage(forCode: $0.rawValue) }
                ?? strings.string(for: .paymentRequestStatusFailedSubtext)
            dispatch(.submissionEnd(.init(
                reason: "PAYMENT_REQUEST_FAILED",
                userErrorMessages: [
                    strings.string(for: .paymentRequestStatusFailedTitle),
                    message
                ],
                developerError: .init(type: .failure, code: pr.failureCode?.rawValue ?? "UNKNOWN")
            )))

        case .canceled:
            let message = pr.failureCode.flatMap { strings.failureMessage(forCode: $0.rawValue) }
                ?? strings.string(for: .paymentRequestStatusCanceledSubtext)
            dispatch(.submissionEnd(.init(
                reason: "PAYMENT_REQUEST_CANCELED",
                userErrorMessages: [
                    strings.string(for: .paymentRequestStatusCanceledTitle),
                    message
                ],
                developerError: .init(type: .failure, code: "PAYMENT_REQUEST_CANCELED")
            )))

        case .expired:
            let message = pr.failureCode.flatMap { strings.failureMessage(forCode: $0.rawValue) }
                ?? strings.string(for: .paymentRequestStatusExpiredSubtext)
            dispatch(.submissionEnd(.init(
                reason: "PAYMENT_REQUEST_EXPIRED",
                userErrorMessages: [
                    strings.string(for: .paymentRequestStatusExpiredTitle),
                    message
                ],
                developerError: .init(type: .failure, code: "PAYMENT_REQUEST_EXPIRED")
            )))

        case .requiresAction, .pending, .unknown:
            break
        }

        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    private func handleFinalPaymentTokenStatus(_ pt: PaymentTokenResponse) -> AnyPublisher<Void, Error> {
        stateStore.isSubmitting = false
        let strings = XenditStrings(locale: stateStore.session?.locale ?? "en")

        switch pt.status {
        case .active:
            dispatch(.sessionComplete)

        case .failed, .canceled, .expired:
            let message = pt.failureCode.flatMap { strings.failureMessage(forCode: $0.rawValue) }
                ?? strings.string(for: .paymentTokenStatusFailedSubtext)
            dispatch(.submissionEnd(.init(
                reason: "PAYMENT_TOKEN_\(pt.status)",
                userErrorMessages: [
                    strings.string(for: .paymentTokenStatusFailedTitle),
                    message
                ],
                developerError: .init(type: .failure, code: pt.failureCode?.rawValue ?? "UNKNOWN")
            )))

        case .requiresAction, .pending, .unknown:
            break
        }

        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    // MARK: - Polling

    private func startPolling(
        parsedKey: ParsedSdkKey,
        tokenRequestId: String?
    ) -> AnyPublisher<Void, Error> {
        stateStore.isPolling = true
        return Future<Void, Error> { [weak self] promise in
            guard let self else {
                promise(.failure(URLError(.cancelled)))
                return
            }
            self.poller.startPolling(
                checkoutAPI: self.checkoutAPI,
                sessionAuthKey: parsedKey.sessionAuthKey,
                tokenRequestId: tokenRequestId
            ) { [weak self] result in
                guard let self else { return }
                self.handlePollResult(result)
                if case .continuePolling = result { return }
                self.stateStore.isPolling = false
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    private func handlePollResult(_ result: PollResult) {
        dispatch(.actionEnd)
        stateStore.awaitingPaymentAction = nil
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
            let message = failureCode.flatMap { strings.failureMessage(forCode: $0.rawValue) }
                ?? strings.string(for: .paymentRequestStatusFailedSubtext)
            dispatch(.submissionEnd(.init(
                reason: "PAYMENT_REQUEST_FAILED",
                userErrorMessages: [
                    strings.string(for: .paymentRequestStatusFailedTitle),
                    message
                ],
                developerError: .init(type: .failure, code: failureCode?.rawValue ?? "UNKNOWN")
            )))

        case .paymentTokenCreated:
            dispatch(.sessionComplete)

        case .paymentTokenFailed(_, let failureCode):
            let message = failureCode.flatMap { strings.failureMessage(forCode: $0.rawValue) }
                ?? strings.string(for: .paymentRequestStatusFailedSubtext)
            dispatch(.submissionEnd(.init(
                reason: "PAYMENT_TOKEN_FAILED",
                userErrorMessages: [
                    strings.string(for: .paymentTokenStatusFailedTitle),
                    message
                ],
                developerError: .init(type: .failure, code: failureCode?.rawValue ?? "UNKNOWN")
            )))

        case .continuePolling:
            break

        case .requiresAction:
            break

        case .pollFailed(let errorCode, let message):
            dispatch(.submissionEnd(.init(
                reason: "POLL_FAILED",
                userErrorMessages: [
                    strings.string(for: .paymentRequestStatusFailedTitle),
                    message
                ],
                developerError: .init(type: .failure, code: errorCode)
            )))
        }
    }
    
    // MARK: - Simulate payment

    func simulatePaymentIfNeeded() -> AnyPublisher<Void, Error> {
        guard stateStore.session?.sessionType == .pay else { return Result.success(()).publisher.eraseToAnyPublisher() }
        guard parsedKey?.hostId != "pl" else { return Result.success(()).publisher.eraseToAnyPublisher() }
        guard let key = parsedKey,
              let prId = lastPaymentRequestId,
              let channelCode = stateStore.currentChannel?.channelCode else { return Result.success(()).publisher.eraseToAnyPublisher() }
        return Future<Void, Error> { [weak self] promise in
            guard let self else {
                promise(.failure(URLError(.cancelled)))
                return
            }
            checkoutAPI.simulatePayment(
                sessionAuthKey: key.sessionAuthKey,
                paymentRequestId: prId,
                channelCode: channelCode
            ).sink(receiveCompletion: { _ in
                promise(.success(()))
            }, receiveValue: { _ in }
            )
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Apple Pay submission

extension XenditComponents {
    func performApplePaySubmission(
        channel: SessionResponse.Channel,
        channelProperties: [String: Any],
        parsedKey: ParsedSdkKey
    ) -> AnyPublisher<SubmissionResult, Error> {
        let query = PaymentRequestQuery(
            sessionId: parsedKey.sessionAuthKey,
            channelCode: channel.channelCode,
            channelProperties: channelProperties
        )
        return checkoutAPI.createPaymentRequest(query: query)
            .map { SubmissionResult.paymentRequest($0) }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    func submitApplePay(channelProperties: [String: Any]) {
        let strings = XenditStrings(locale: stateStore.session?.locale ?? "en")

        func failWith(_ code: String) {
            dispatch(.submissionEnd(.init(
                reason: "APPLE_PAY_FAILED",
                userErrorMessages: [
                    strings.string(for: .applePayErrorsUnknownErrorTitle),
                    strings.string(for: .applePayErrorsUnknownErrorMessage)
                ],
                developerError: .init(type: .failure, code: code)
            )))
        }

        guard let channel = stateStore.channels.first(where: {
            $0.pmType == .cards &&
            $0.isInAmountRange(for: .pay, amount: stateStore.session?.amount ?? 0)
        }) else {
            return failWith("APPLE_PAY_NO_CARDS_CHANNEL")
        }
        guard let parsedKey, stateStore.session != nil else {
            return failWith("APPLE_PAY_NOT_INITIALIZED")
        }

        stateStore.isSubmitting = true
        dispatch(.submissionBegin)

        performApplePaySubmission(channel: channel, channelProperties: channelProperties, parsedKey: parsedKey)
            .flatMap { [weak self] result -> AnyPublisher<Void, Error> in
                guard let self else { return Fail(error: URLError(.cancelled)).eraseToAnyPublisher() }
                return self.handleSubmissionResult(result, parsedKey: parsedKey)
            }
            .handleEvents(receiveCompletion: { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.stateStore.isSubmitting = false
                if let clientError = error as? APIClientError, clientError.type == .noInternet {
                    self?.dispatch(.submissionEnd(.init(
                        reason: "REQUEST_FAILED",
                        userErrorMessages: [
                            strings.string(for: .networkErrorTitle),
                            strings.string(for: .networkErrorSubtext)
                        ],
                        developerError: .init(type: .networkError, code: clientError.errorCode)
                    )))
                } else if let clientError = error as? APIClientError,
                          let backendError = clientError.backendError {
                    if let content = backendError.errorContent {
                        self?.dispatch(.submissionEnd(.init(
                            reason: "REQUEST_FAILED",
                            userErrorMessages: [content.title, content.message1, content.message2].compactMap { $0 },
                            developerError: .init(type: .failure, code: backendError.code)
                        )))
                    } else {
                        self?.dispatch(.submissionEnd(.init(
                            reason: "REQUEST_FAILED",
                            userErrorMessages: [strings.string(for: .defaultErrorTitle), backendError.message],
                            developerError: .init(type: .failure, code: backendError.code)
                        )))
                    }
                } else {
                    self?.dispatch(.submissionEnd(.init(
                        reason: "REQUEST_FAILED",
                        userErrorMessages: [
                            strings.string(for: .applePayErrorsUnknownErrorTitle),
                            strings.string(for: .applePayErrorsUnknownErrorMessage)
                        ],
                        developerError: .init(type: .networkError, code: "NETWORK_ERROR")
                    )))
                }
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}


// MARK: - SubmissionResult

enum SubmissionResult {
    case paymentRequest(PaymentRequestResponse)
    case paymentToken(PaymentTokenResponse)
}
