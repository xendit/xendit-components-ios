//
//  QrChannelGroupUI.swift
//  XenditComponents
//
//  Created by Ahmad X on 16/06/2026.
//

import Lottie
import SwiftUI

struct QrChannelGroupUI: View {
    let channel: SessionResponse.Channel
    let session: Session
    @ObservedObject var stateStore: SDKStateStore
    let onPropertiesChanged: (ChannelProperties) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s1) {
            if hasFormContent(channel, session: session) {
                ChannelFormContent(channel: channel, session: session, stateStore: stateStore, onPropertiesChanged: onPropertiesChanged)
            }
            if let instructions = channel.instructions, !instructions.isEmpty {
                QrInstructionsView(instructions: instructions)
            }
        }
    }
}

// MARK: - QR instructions panel

struct QrInstructionsView: View {
    let instructions: [String]

    var body: some View {
        let a = XenditComponents.appearance
        VStack(spacing: 0) {
            DashedDivider(color: a.resolvedBorder)
                .frame(height: 1)
            HStack(alignment: .center, spacing: Spacing.s3) {
                LottieView(animation: .named("qr_scanner", bundle: .module))
                    .looping()
                    .frame(width: 60, height: 60)
                    .offset(y: -2)
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
