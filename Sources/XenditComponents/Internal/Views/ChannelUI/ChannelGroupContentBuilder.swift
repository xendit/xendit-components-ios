//
//  ChannelGroupContentBuilder.swift
//  XenditComponents
//
//  Created by Ahmad X on 16/06/2026.
//

import SwiftUI

/// Maps a channel group to the appropriate inline content view.
/// Add a new case here (and a new channel UI file) when a new channel type is introduced.
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
            EWalletChannelGroupUI(
                channels: channels,
                group: group,
                selectedChannel: selectedChannel,
                session: session,
                stateStore: stateStore,
                onPropertiesChanged: onPropertiesChanged,
                onChannelSelected: onChannelSelected
            )
        case .qrCode:
            if let channel = selectedChannel ?? channels.first {
                QrChannelGroupUI(
                    channel: channel,
                    session: session,
                    stateStore: stateStore,
                    onPropertiesChanged: onPropertiesChanged
                )
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

// MARK: - Shared bullet-list instructions view (Cards, Generic)

struct BulletInstructionsView: View {
    let instructions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(instructions, id: \.self) { instruction in
                Text("• \(instruction)")
                    .font(InterFont.captionRegular)
                    .foregroundColor(XenditComponents.appearance.resolvedTextSecondary)
            }
        }
        .padding(.horizontal, 20)
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
