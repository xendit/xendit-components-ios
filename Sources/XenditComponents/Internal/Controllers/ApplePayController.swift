//
//  ApplePayController.swift
//  XenditComponents
//
//  Created by Ahmad X on 12/08/2026.
//

import Contacts
import Foundation
import PassKit

final class ApplePayController: NSObject {
    private weak var sdk: XenditComponents?
    private let applePayData: SessionResponse.DigitalWallets.ApplePay
    private let parsedKey: ParsedSdkKey
    private var pkController: PKPaymentAuthorizationController?

    init(
        sdk: XenditComponents,
        applePayData: SessionResponse.DigitalWallets.ApplePay,
        session: Session,
        parsedKey: ParsedSdkKey
    ) {
        self.sdk = sdk
        self.applePayData = applePayData
        self.parsedKey = parsedKey
    }

    func present() {
        let request = buildPaymentRequest()
        guard PKPaymentAuthorizationController.canMakePayments(usingNetworks: request.supportedNetworks) else {
            return
        }
        let controller = PKPaymentAuthorizationController(paymentRequest: request)
        controller.delegate = self
        pkController = controller
        controller.present(completion: nil)
    }

    // MARK: - PKPaymentRequest construction

    private func buildPaymentRequest() -> PKPaymentRequest {
        let req = PKPaymentRequest()
        let data = applePayData.applePayPaymentRequest
        req.merchantIdentifier = applePayData.merchantId
        req.countryCode = data.countryCode
        req.currencyCode = data.currencyCode
        req.merchantCapabilities = Self.pkMerchantCapabilities(from: data.merchantCapabilities)
        req.supportedNetworks = Self.pkNetworks(from: data.supportedNetworks)
        let summaryItemType: PKPaymentSummaryItemType = data.total.type == "pending" ? .pending : .final
        req.paymentSummaryItems = [
            PKPaymentSummaryItem(
                label: data.total.label,
                amount: NSDecimalNumber(string: data.total.amount),
                type: summaryItemType
            )
        ]
        if let billing = data.requiredBillingContactFields {
            req.requiredBillingContactFields = Self.pkContactFields(from: billing)
        }
        if let shipping = data.requiredShippingContactFields {
            req.requiredShippingContactFields = Self.pkContactFields(from: shipping)
        }
        return req
    }

    // MARK: - Network/capability mapping (static so ApplePayButtonView can reuse)

    static func pkNetworks(from strings: [String]) -> [PKPaymentNetwork] {
        strings.compactMap { name in
            switch name.lowercased() {
            case "visa":          return .visa
            case "mastercard":    return .masterCard
            case "amex":          return .amex
            case "discover":      return .discover
            case "jcb":           return .JCB
            case "chinaunionpay": return .chinaUnionPay
            case "maestro":       return .maestro
            case "elo":           return .elo
            case "mada":          return .mada
            default:              return nil
            }
        }
    }

    static func pkContactFields(from strings: [String]) -> Set<PKContactField> {
        var fields: Set<PKContactField> = []
        for s in strings {
            switch s {
            case "postalAddress": fields.insert(.postalAddress)
            case "name":          fields.insert(.name)
            case "email":         fields.insert(.emailAddress)
            case "phone":         fields.insert(.phoneNumber)
            default: break
            }
        }
        return fields
    }

    static func pkMerchantCapabilities(from strings: [String]) -> PKMerchantCapability {
        var caps: PKMerchantCapability = []
        for s in strings {
            switch s {
            case "supports3DS":    caps.insert(.capability3DS)
            case "supportsEMV":    caps.insert(.capabilityEMV)
            case "supportsCredit": caps.insert(.capabilityCredit)
            case "supportsDebit":  caps.insert(.capabilityDebit)
            default: break
            }
        }
        return caps.isEmpty ? .capability3DS : caps
    }

    // MARK: - Token serialization

    private func buildChannelProperties(from payment: PKPayment) -> [String: Any]? {
        guard let tokenData = try? JSONSerialization.jsonObject(with: payment.token.paymentData) else {
            return nil
        }
        let typeString: String = {
            switch payment.token.paymentMethod.type {
            case .credit:  return "credit"
            case .debit:   return "debit"
            case .prepaid: return "prepaid"
            case .store:   return "store"
            default:       return "unknown"
            }
        }()
        var payload: [String: Any] = [
            "token": [
                "paymentData": tokenData,
                "paymentMethod": [
                    "displayName": payment.token.paymentMethod.displayName ?? "",
                    "network": payment.token.paymentMethod.network?.rawValue ?? "",
                    "type": typeString
                ],
                "transactionIdentifier": payment.token.transactionIdentifier
            ]
        ]
        if let billing = pkContactDict(from: payment.billingContact) {
            payload["billingContact"] = billing
        }
        if let shipping = pkContactDict(from: payment.shippingContact) {
            payload["shippingContact"] = shipping
        }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return ["apple_pay": jsonString]
    }

    private func pkContactDict(from contact: PKContact?) -> [String: Any]? {
        guard let contact else { return nil }
        var dict: [String: Any] = [:]
        if let name = contact.name {
            dict["givenName"] = name.givenName
            dict["familyName"] = name.familyName
            if let phonetic = name.phoneticRepresentation {
                dict["phoneticGivenName"] = phonetic.givenName
                dict["phoneticFamilyName"] = phonetic.familyName
            }
        }
        if let email = contact.emailAddress { dict["emailAddress"] = email }
        if let phone = contact.phoneNumber { dict["phoneNumber"] = phone.stringValue }
        if let address = contact.postalAddress {
            let lines = address.street.components(separatedBy: "\n").filter { !$0.isEmpty }
            if !lines.isEmpty { dict["addressLines"] = lines }
            if !address.subLocality.isEmpty { dict["subLocality"] = address.subLocality }
            if !address.city.isEmpty { dict["locality"] = address.city }
            if !address.postalCode.isEmpty { dict["postalCode"] = address.postalCode }
            if !address.subAdministrativeArea.isEmpty { dict["subAdministrativeArea"] = address.subAdministrativeArea }
            if !address.state.isEmpty { dict["administrativeArea"] = address.state }
            if !address.country.isEmpty { dict["country"] = address.country }
            if !address.isoCountryCode.isEmpty { dict["countryCode"] = address.isoCountryCode }
        }
        return dict.isEmpty ? nil : dict
    }
}

// MARK: - PKPaymentAuthorizationControllerDelegate

extension ApplePayController: PKPaymentAuthorizationControllerDelegate {
    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        guard let channelProperties = buildChannelProperties(from: payment) else {
            handler(PKPaymentAuthorizationResult(status: .failure, errors: nil))
            return
        }
        // Signal success immediately — mirrors web's completePayment(STATUS_SUCCESS) before submission
        handler(PKPaymentAuthorizationResult(status: .success, errors: nil))
        Task { @MainActor in
            self.sdk?.submitApplePay(channelProperties: channelProperties)
        }
    }

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss(completion: nil)
        Task { @MainActor in
            self.sdk?.applePayController = nil
        }
    }
}
