//
//  ApplePayButtonView.swift
//  XenditComponents
//
//  Created by Ahmad X on 12/08/2026.
//

import SwiftUI
import PassKit

struct ApplePayButtonView: View {
    private weak var sdk: XenditComponents?
    @ObservedObject private var state: SDKStateStore

    init(sdk: XenditComponents) {
        self.sdk = sdk
        self.state = sdk.stateStore
    }

    private var strings: XenditStrings {
        XenditStrings(locale: state.session?.locale ?? "en")
    }

    private var isAvailable: Bool {
        guard state.session?.sessionType == .pay else { return false }
        guard let applePay = state.digitalWallets?.applePay else { return false }
        let networks = ApplePayController.pkNetworks(from: applePay.applePayPaymentRequest.supportedNetworks)
        return PKPaymentAuthorizationController.canMakePayments(usingNetworks: networks)
    }

    var body: some View {
        if isAvailable, let sdk {
            VStack(spacing: 12) {
                PKPaymentButtonRepresentable {
                    sdk.presentApplePay()
                }
                .frame(height: 50)
                .cornerRadius(XenditComponents.appearance.resolvedRadius)

                HStack(spacing: 8) {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(XenditComponents.appearance.resolvedBorder)
                    Text(strings.string(for: .paymentMethodsDigitalWalletOr))
                        .font(.labelMdRegular)
                        .foregroundColor(.secondary)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(XenditComponents.appearance.resolvedBorder)
                }
            }
            .padding(.bottom, 4)
        }
    }
}

// MARK: - PKPaymentButton wrapper

private struct PKPaymentButtonRepresentable: UIViewRepresentable {
    let onTap: () -> Void

    func makeUIView(context: Context) -> PKPaymentButton {
        let button = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.didTap), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: PKPaymentButton, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onTap: onTap) }

    final class Coordinator: NSObject {
        let onTap: () -> Void
        init(onTap: @escaping () -> Void) { self.onTap = onTap }
        @objc func didTap() { onTap() }
    }
}
