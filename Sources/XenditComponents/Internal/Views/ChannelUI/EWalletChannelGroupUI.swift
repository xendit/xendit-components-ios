//
//  EWalletChannelGroupUI.swift
//  XenditComponents
//
//  Created by Ahmad X on 16/06/2026.
//

import SwiftUI

struct EWalletChannelGroupUI: View {
    let channels: [SessionResponse.Channel]
    let group: SessionResponse.ChannelUIGroup
    let selectedChannel: SessionResponse.Channel?
    let session: Session
    @ObservedObject var stateStore: SDKStateStore
    let onPropertiesChanged: (ChannelProperties) -> Void
    let onChannelSelected: (SessionResponse.Channel) -> Void

    var body: some View {
        if channels.count > 1 {
            multiChannelContent
        } else if let channel = channels.first {
            singleChannelContent(channel)
        }
    }

    // MARK: - Multi-channel (dropdown + optional form + instructions)

    @ViewBuilder
    private var multiChannelContent: some View {
        let strings = XenditStrings(locale: session.locale)
        VStack(alignment: .leading, spacing: Spacing.s3) {
            DropdownFieldView(
                label: strings.string(for: .paymentMethodsPayWith),
                placeholder: strings.string(
                    for: .paymentMethodsSelectChannelPlaceholder,
                    replacements: ["groupName": group.label]
                ),
                options: ewalletPickerOptions,
                value: ewalletPickerBinding,
                showIconDivider: true
            )
            if let channel = selectedChannel {
                if hasFormContent(channel, session: session) {
                    ChannelFormContent(channel: channel, session: session, stateStore: stateStore, onPropertiesChanged: onPropertiesChanged)
                }
                if let instructions = channel.instructions, !instructions.isEmpty {
                    EwalletInstructionsView(instructions: instructions)
                }
            }
        }
    }

    // MARK: - Single-channel (form + instructions)

    @ViewBuilder
    private func singleChannelContent(_ channel: SessionResponse.Channel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s1) {
            if hasFormContent(channel, session: session) {
                ChannelFormContent(channel: channel, session: session, stateStore: stateStore, onPropertiesChanged: onPropertiesChanged)
            }
            if let instructions = channel.instructions, !instructions.isEmpty {
                EwalletInstructionsView(instructions: instructions)
            }
        }
    }

    // MARK: - Helpers

    private var ewalletPickerOptions: [DropdownFieldView.Option] {
        let sessionType = SessionResponse.Session.SessionType(session.sessionType)
        return channels.map { channel in
            let reason = channel.amountDisabledReason(for: sessionType, amount: session.amount, locale: session.locale)
            return DropdownFieldView.Option(
                label: channel.brandName,
                value: channel.channelCode,
                subtitle: reason,
                iconUrl: channel.brandLogoUrl.isEmpty ? nil : channel.brandLogoUrl,
                isDisabled: reason != nil
            )
        }
    }

    private var ewalletPickerBinding: Binding<String> {
        Binding<String>(
            get: { selectedChannel?.channelCode ?? "" },
            set: { code in
                if let ch = channels.first(where: { $0.channelCode == code }) {
                    onChannelSelected(ch)
                }
            }
        )
    }
}

// MARK: - eWallet instructions panel

struct EwalletInstructionsView: View {
    let instructions: [String]

    var body: some View {
        let a = XenditComponents.appearance
        VStack(spacing: 0) {
            DashedDivider(color: a.resolvedBorder)
                .frame(height: 1)
            HStack(alignment: .center, spacing: Spacing.s3) {
                Image("xdt_icon_phone", bundle: .module)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 40)
                    .foregroundColor(a.resolvedText)
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
                        Text(instruction)
                            .font(index == 0 ? InterFont.labelSmBold : InterFont.captionRegular)
                            .foregroundColor(index == 0 ? a.resolvedText : a.resolvedTextSecondary)
                    }
                }
                Spacer()
            }
            .padding(.vertical, Spacing.s2)
        }
    }
}
