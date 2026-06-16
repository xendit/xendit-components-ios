//
//  XenditChannelPickerView.swift
//  XenditComponents
//
//  Created by Ahmad X on 02/05/2026.
//

import SwiftUI

/// A SwiftUI view that renders the Xendit channel picker.
///
/// Embed this view in your payment screen. It shows an accordion list of payment method groups.
/// - Single-channel groups auto-select their channel and reveal the form inline when expanded.
/// - Multi-channel groups open a bottom sheet so the user can pick a specific channel;
///   the form then appears inline once a channel is chosen.
///
/// Requires `XenditComponents` to be initialized and passed in.
///
/// Example:
/// ```swift
/// XenditChannelPickerView(sdk: sdk)
/// ```
struct XenditChannelPickerView: View {
    @ObservedObject private var state: SDKStateStore
    private weak var sdk: XenditComponents?

    init(sdk: XenditComponents) {
        self.sdk = sdk
        self.state = sdk.stateStore
    }

    var body: some View {
        Group {
            switch state.sdkStatus {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 60)
            case .active:
                if let session = state.session {
                    channelPickerContent(session: session)
                }
            case .fatalError:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private func channelPickerContent(session: Session) -> some View {
        // Collect only groups that have at least one matching channel.
        let visibleGroups = state.channelUiGroups.filter { group in
            state.channels.contains { $0.uiGroup == group.id }
        }

        VStack(spacing: -8) {
            ForEach(Array(visibleGroups.enumerated()), id: \.element.id) { index, group in
                let groupChannels = state.channels.filter { $0.uiGroup == group.id }
                AccordionGroupView(
                    group: group,
                    channels: groupChannels,
                    session: session,
                    selectedChannelCode: state.currentChannel?.channelCode,
                    isLastInGroup: index == visibleGroups.count - 1,
                    stateStore: state,
                    onPropertiesChanged: { sdk?.updateChannelProperties($0) },
                    onChannelSelected: { channel in
                        sdk?.setCurrentResponseChannel(channel)
                    }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Accordion Group

private struct AccordionGroupView: View {
    let group: SessionResponse.ChannelUIGroup
    let channels: [SessionResponse.Channel]
    let session: Session
    let selectedChannelCode: String?
    let isLastInGroup: Bool
    @ObservedObject var stateStore: SDKStateStore
    let onPropertiesChanged: (ChannelProperties) -> Void
    var onChannelSelected: ((SessionResponse.Channel) -> Void)?

    @State private var isManuallyCollapsed: Bool = false
    @State private var showChannelPicker: Bool = false
    @State private var isEwalletExpanded: Bool = false

    private var isSingleChannel: Bool { channels.count == 1 }
    private var isEwalletMultiChannel: Bool { channels.count > 1 && channels.first?.pmType == .ewallet }

    private var isSelected: Bool {
        let hasChannel = channels.contains { $0.channelCode == selectedChannelCode }
        return isEwalletMultiChannel ? (isEwalletExpanded || hasChannel) : hasChannel
    }

    private var selectedChannel: SessionResponse.Channel? {
        channels.first { $0.channelCode == selectedChannelCode }
    }

    private var activeChannel: SessionResponse.Channel? {
        isSingleChannel ? channels.first : selectedChannel
    }

    private var shouldBeOpen: Bool { isSelected && !isManuallyCollapsed }

    private var localChannelIconName: String? {
        switch channels.first?.pmType {
        case .cards:        return "xdt_channel_card"
        case .ewallet:      return "xdt_channel_ewallet"
        case .qrCode:       return "xdt_channel_qr"
        default:            return nil
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerButton

            if shouldBeOpen {
                inlineContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(XenditComponents.appearance.resolvedBackground)
        .cornerRadius(8)
        .overlay(
            Group {
                if isLastInGroup {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(XenditComponents.appearance.resolvedBorder, lineWidth: 1)
                } else {
                    UnevenRoundedRectangle(radii: .top(8))
                        .stroke(XenditComponents.appearance.resolvedBorder, lineWidth: 1)
                }
            }
        )
        .animation(.easeInOut(duration: 0.2), value: shouldBeOpen)
        .onChange(of: selectedChannelCode) { newCode in
            isManuallyCollapsed = false
            if isEwalletMultiChannel, let code = newCode {
                if !channels.contains(where: { $0.channelCode == code }) {
                    isEwalletExpanded = false
                }
            }
        }
        .sheet(isPresented: $showChannelPicker) {
            ChannelPickerSheet(
                group: group,
                channels: channels,
                session: session,
                selectedChannelCode: selectedChannelCode,
                onChannelSelected: { channel in
                    onChannelSelected?(channel)
                    showChannelPicker = false
                }
            )
        }
    }

    // MARK: Header

    private var headerButton: some View {
        Button(action: handleHeaderTap) {
            HStack(spacing: Spacing.s4) {
                let iconColor: Color = isSelected
                    ? XenditComponents.appearance.resolvedPrimary
                    : XenditComponents.appearance.resolvedText

                AsyncImage(url: URL(string: group.iconUrl)) { image in
                    image
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(iconColor)
                } placeholder: {
                    if let assetName = localChannelIconName {
                        Image(assetName, bundle: .module)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(iconColor)
                    } else {
                        Image(systemName: "creditcard")
                            .foregroundColor(iconColor)
                    }
                }
                .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(group.label)
                        .font(isSelected ? .labelLgBold : .labelLgRegular)
                        .foregroundColor(
                            isSelected
                                ? XenditComponents.appearance.resolvedPrimary
                                : XenditComponents.appearance.resolvedText
                        )
                }

                Spacer()

                Image(systemName: shouldBeOpen ? "chevron.up" : "chevron.down")
                    .font(.subheadline)
                    .foregroundColor(XenditComponents.appearance.resolvedText)
            }
            .padding(.horizontal, Spacing.s4)
            .padding(.top, Spacing.s6)
            .padding(.bottom, isLastInGroup ? Spacing.s6 : 32)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: Inline content

    @ViewBuilder
    private var inlineContent: some View {
        if let session = stateStore.session {
            ChannelGroupContentBuilder.make(
                channels: channels,
                group: group,
                selectedChannel: activeChannel,
                session: session,
                stateStore: stateStore,
                onPropertiesChanged: onPropertiesChanged,
                onChannelSelected: onChannelSelected ?? { _ in }
            )
            .padding(.horizontal, Spacing.s4)
            .padding(.bottom, Spacing.s4)
        }
    }

    // MARK: Actions

    private func handleHeaderTap() {
        if isSingleChannel {
            if isSelected {
                isManuallyCollapsed.toggle()
            } else {
                onChannelSelected?(channels[0])
            }
        } else if isEwalletMultiChannel {
            if shouldBeOpen {
                isEwalletExpanded = false
                isManuallyCollapsed = true
            } else {
                isEwalletExpanded = true
                isManuallyCollapsed = false
            }
        } else {
            showChannelPicker = true
        }
    }
}

// MARK: - Channel Picker Bottom Sheet (multi-channel)

private struct ChannelPickerSheet: View {
    let group: SessionResponse.ChannelUIGroup
    let channels: [SessionResponse.Channel]
    let session: Session
    let selectedChannelCode: String?
    var onChannelSelected: ((SessionResponse.Channel) -> Void)?

    var body: some View {
        NavigationView {
            List {
                ForEach(channels, id: \.channelCode) { channel in
                    channelRow(channel)
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
            }
            .listStyle(.plain)
            .navigationTitle(group.label)
            .navigationBarTitleDisplayMode(.inline)
        }
        .modifier(SheetDetentsModifier())
    }

    private func channelRow(_ channel: SessionResponse.Channel) -> some View {
        let isSelected = channel.channelCode == selectedChannelCode
        let sessionType: SessionResponse.Session.SessionType = session.sessionType == .pay ? .pay : .save
        let isDisabled = !channel.isInAmountRange(for: sessionType, amount: session.amount)

        return Button(action: {
            guard !isDisabled else { return }
            onChannelSelected?(channel)
        }) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: channel.brandLogoUrl)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Color(.systemGray5)
                }
                .frame(width: 40, height: 40)
                .cornerRadius(6)

                Text(channel.brandName)
                    .font(InterFont.bodyMd)
                    .foregroundColor(isDisabled ? .secondary : .primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(XenditComponents.appearance.resolvedPrimary)
                }
            }
            .padding(.vertical, 12)
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

// MARK: - Presentation detents helper (iOS 16+)

struct SheetDetentsModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        } else {
            content
        }
    }
}

