//
//  AwaitingPaymentView.swift
//  XenditComponents
//
//  Created by Ahmad X on 16/06/2026.
//

import SwiftUI

struct AwaitingPaymentView: View {
    let action: AwaitingPaymentAction
    let channelName: String
    let channelLogoUrl: String?
    let locale: String
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            card
                .padding(.horizontal, 24)
        }
    }

    private var card: some View {
        let a = XenditComponents.appearance
        let strings = XenditStrings(locale: locale)
        let resolvedName = channelName.isEmpty ? "payment" : channelName

        return VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(a.resolvedTextSecondary)
                }
                .accessibilityIdentifier(XenditA11yIds.awaitingPaymentDialogClose)
            }

            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 92, height: 92)

                if let urlStr = channelLogoUrl, !urlStr.isEmpty {
                    RemoteImage(url: URL(string: urlStr))
                        .frame(width: 64, height: 40)
                }
            }
            .padding(.top, 4)
            .padding(.bottom, 16)

            Text(strings.string(for: .actionDeeplinkTitle))
                .font(InterFont.labelLgBold)
                .foregroundColor(a.resolvedText)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 6)

            Text(subtitle(strings, channelName: resolvedName))
                .font(InterFont.bodyMd)
                .foregroundColor(a.resolvedTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }

    private func subtitle(_ strings: XenditStrings, channelName: String) -> String {
        switch action {
        case .deeplink:
            return strings.string(for: .actionDeeplinkInstructions, replacements: ["channelName": channelName])
        case .emptyPaymentActions:
            return strings.string(for: .actionEmptyListPushNotificationSubtext, replacements: ["channelName": channelName])
        }
    }
}
