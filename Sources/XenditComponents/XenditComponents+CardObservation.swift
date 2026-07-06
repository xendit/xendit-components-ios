//
//  XenditComponents+CardObservation.swift
//  XenditComponents
//
//  Created by Ahmad X on 01/05/2026.
//

import Combine
import Foundation

// MARK: - Card number observation

extension XenditComponents {

    /// Subscribes to `stateStore.cardNumber` changes and triggers BIN lookup + installment
    /// plan fetching after a 300 ms debounce. Called once from `init`.
    func setupCardNumberObservation() {
        stateStore.$cardNumber
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] number in
                self?.handleCardNumberChange(number)
            }
            .store(in: &cancellables)
    }

    private func handleCardNumberChange(_ number: String) {
        let cleanNumber = number.replacingOccurrences(of: " ", with: "")

        guard cleanNumber.count >= 6 else {
            stateStore.cardDetails = nil
            stateStore.installmentPlans = nil
            return
        }

        guard let sessionAuthKey = stateStore.session?.id,
              let publicKey = parsedKey?.publicKey else { return }

        let encryptedCardNumber: String
        do {
            encryptedCardNumber = try XenditEncryption.encrypt(
                data: cleanNumber,
                serverPublicKeyBase64: publicKey,
                sessionId: sessionAuthKey
            )
        } catch {
            Logger.warning("Failed to encrypt card number: \(error)")
            return
        }

        fetchCardInfo(sessionAuthKey: sessionAuthKey, encryptedCardNumber: encryptedCardNumber)

        if stateStore.session != nil, FormValidator.validateCreditCard(cleanNumber) {
            fetchInstallmentPlans(
                sessionAuthKey: sessionAuthKey,
                encryptedCardNumber: encryptedCardNumber
            )
        }
    }

    private func fetchCardInfo(sessionAuthKey: String, encryptedCardNumber: String) {
        checkoutAPI
            .getCardInfo(
                sessionAuthKey: sessionAuthKey,
                query: CardInfoQuery(cardNumber: encryptedCardNumber)
            )
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] details in
                self?.stateStore.cardDetails = details
                self?.handleCardDetailsResolved(details)
            })
            .store(in: &cancellables)
    }

    private func fetchInstallmentPlans(sessionAuthKey: String, encryptedCardNumber: String) {
        let query = PaymentOptionsQuery(
            channelCode: "CARDS",
            channelProperties: ["card_number": encryptedCardNumber]
        )
        checkoutAPI
            .getPaymentOptions(sessionAuthKey: sessionAuthKey, query: query)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] options in
                guard let self else { return }
                var plans = options.installmentPlans?.map { InstallmentPlan.from($0, currency: options.currency) } ?? []
                if !plans.isEmpty {
                    plans.insert(.payInFull(amount: options.amount, currency: options.currency), at: 0)
                }
                self.stateStore.installmentPlans = plans
                // Pre-select Pay in Full (first option, no installment channel properties written).
                self.stateStore.selectedInstallmentPlan = plans.first
            })
            .store(in: &cancellables)
    }

    private func handleCardDetailsResolved(_ details: CardInfoResponse) {
        guard let countryCode = details.countryCodes.first else { return }

        // Pass the ISO code directly — inferring from the dial-code prefix is ambiguous
        // for shared codes like +1 (US and CA). PhoneNumberFieldView reacts via onChange.
        stateStore.phoneCountryCode = countryCode

        guard details.requireBillingInformation else { return }
        var props = stateStore.channelProperties
        props["billing_information.country"] = countryCode
        stateStore.channelProperties = props
    }
}
