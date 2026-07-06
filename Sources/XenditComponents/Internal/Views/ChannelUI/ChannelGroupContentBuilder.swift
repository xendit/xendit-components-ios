//
//  ChannelGroupContentBuilder.swift
//  XenditComponents
//
//  Created by Ahmad X on 16/06/2026.
//

import Lottie
import SwiftUI

/// Maps a channel group to the appropriate inline content view.
enum ChannelGroupContentBuilder {
    @ViewBuilder
    static func make(
        channels: [SessionResponse.Channel],
        group: SessionResponse.ChannelUIGroup,
        selectedChannel: SessionResponse.Channel?,
        session: Session,
        stateStore: SDKStateStore,
        onPropertiesChanged: @escaping (ChannelProperties) -> Void,
        onChannelSelected: @escaping (SessionResponse.Channel) -> Void
    ) -> some View {
        switch channels.first?.pmType {
        case .ewallet:
            PickerChannelGroupUI(channels: channels, group: group, selectedChannel: selectedChannel, session: session, stateStore: stateStore, onPropertiesChanged: onPropertiesChanged, onChannelSelected: onChannelSelected) {
                LottieView(animation: .named("redirect_web_url", bundle: .module))
                    .looping()
                    .frame(width: 40, height: 40)
            }
        case .qrCode:
            PickerChannelGroupUI(channels: channels, group: group, selectedChannel: selectedChannel, session: session, stateStore: stateStore, onPropertiesChanged: onPropertiesChanged, onChannelSelected: onChannelSelected) {
                LottieView(animation: .named("qr_scanner", bundle: .module))
                    .looping()
                    .frame(width: 60, height: 60)
                    .offset(y: -2)
            }
        case .cards:
            if let channel = selectedChannel ?? channels.first {
                CardChannelGroupUI(
                    channel: channel,
                    session: session,
                    stateStore: stateStore,
                    onPropertiesChanged: onPropertiesChanged
                )
            }
        case .virtualAccount, .bankTransfer, .directDebit, .overTheCounter:
            PickerChannelGroupUI(channels: channels, group: group, selectedChannel: selectedChannel, session: session, stateStore: stateStore, onPropertiesChanged: onPropertiesChanged, onChannelSelected: onChannelSelected) {
                LottieView(animation: .named("redirect_web_url", bundle: .module))
                    .looping()
                    .frame(width: 40, height: 40)
            }
        default:
            if let channel = selectedChannel ?? channels.first {
                GenericChannelGroupUI(
                    channel: channel,
                    session: session,
                    stateStore: stateStore,
                    onPropertiesChanged: onPropertiesChanged
                )
            }
        }
    }
}

// MARK: - Shared picker-based channel group UI

struct PickerChannelGroupUI<Icon: View>: View {
    let channels: [SessionResponse.Channel]
    let group: SessionResponse.ChannelUIGroup
    let selectedChannel: SessionResponse.Channel?
    let session: Session
    @ObservedObject var stateStore: SDKStateStore
    let onPropertiesChanged: (ChannelProperties) -> Void
    let onChannelSelected: (SessionResponse.Channel) -> Void
    @ViewBuilder let icon: () -> Icon

    var body: some View {
        let strings = XenditStrings(locale: session.locale)
        VStack(alignment: .leading, spacing: Spacing.s3) {
            DropdownFieldView(
                label: strings.string(for: .paymentMethodsPayWith),
                placeholder: strings.string(
                    for: .paymentMethodsSelectChannelPlaceholder,
                    replacements: ["groupName": group.label]
                ),
                options: channels.map {
                    DropdownFieldView.Option(
                        label: $0.brandName,
                        value: $0.channelCode,
                        subtitle: nil,
                        iconUrl: $0.brandLogoUrl.isEmpty ? nil : $0.brandLogoUrl
                    )
                },
                value: Binding(
                    get: { selectedChannel?.channelCode ?? "" },
                    set: { code in
                        if let ch = channels.first(where: { $0.channelCode == code }) {
                            onChannelSelected(ch)
                        }
                    }
                ),
                isDisabled: channels.count == 1,
                showIconDivider: true
            )
            if let channel = selectedChannel {
                if hasFormContent(channel, session: session) {
                    ChannelFormContent(channel: channel, session: session, stateStore: stateStore, onPropertiesChanged: onPropertiesChanged)
                }
                if let banner = channel.banner, !banner.imageUrl.isEmpty {
                    ChannelBannerView(banner: banner)
                }
                if let instructions = channel.instructions, !instructions.isEmpty {
                    ChannelInstructionsView(instructions: instructions, icon: icon)
                }
            }
        }
        .onAppear {
            if channels.count == 1, selectedChannel == nil, let only = channels.first {
                onChannelSelected(only)
            }
        }
    }
}

// MARK: - Shared helpers used across channel group UIs

func hasFormContent(_ channel: SessionResponse.Channel, session: Session) -> Bool {
    !channel.form.isEmpty || session.allowSavePaymentMethod.map { $0 != .disabled } ?? false
}

@MainActor
func effectiveFormChannel(_ channel: SessionResponse.Channel, stateStore: SDKStateStore) -> SessionResponse.Channel {
    guard stateStore.savePaymentMethod,
          let variants = stateStore.channelVariants[channel.channelCode]
    else { return channel }
    return variants.saveChannel
}

// MARK: - Shared form content view

struct ChannelFormContent: View {
    let channel: SessionResponse.Channel
    let session: Session
    @ObservedObject var stateStore: SDKStateStore
    let onPropertiesChanged: (ChannelProperties) -> Void

    var body: some View {
        let effective = effectiveFormChannel(channel, stateStore: stateStore)
        ChannelFormView(
            channel: effective,
            session: session,
            locale: session.locale,
            stateStore: stateStore,
            channelProperties: Binding(
                get: { stateStore.channelProperties },
                set: { stateStore.channelProperties = $0 }
            ),
            onPropertiesChanged: onPropertiesChanged
        )
        .id(effective.channelCode)
    }
}

// MARK: - Shared instructions view with dynamic icon

struct ChannelInstructionsView<Icon: View>: View {
    let instructions: [String]
    @ViewBuilder let icon: () -> Icon

    var body: some View {
        let a = XenditComponents.appearance
        VStack(spacing: 0) {
            DashedDivider(color: a.resolvedBorder)
                .frame(height: 1)
            HStack(alignment: .center, spacing: Spacing.s3) {
                icon()
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

// MARK: - Banner image between form and instructions

struct ChannelBannerView: View {
    let banner: SessionResponse.Channel.Banner

    var body: some View {
        let a = XenditComponents.appearance
        let ratio = (banner.aspectRatio ?? 0) > 0 ? banner.aspectRatio : nil
        RemoteImage(url: URL(string: banner.imageUrl), contentMode: .fill)
            .frame(maxWidth: .infinity)
            .frame(height: ratio == nil ? 72 : nil)
            .aspectRatio(ratio.map { CGFloat($0) }, contentMode: .fill)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: a.resolvedRadius))
    }
}

// MARK: - Shared divider used by instruction views

struct DashedDivider: View {
    let color: Color

    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0.5))
                path.addLine(to: CGPoint(x: geo.size.width, y: 0.5))
            }
            .stroke(color, style: StrokeStyle(lineWidth: 1, dash: [6, 6]))
        }
    }
}
