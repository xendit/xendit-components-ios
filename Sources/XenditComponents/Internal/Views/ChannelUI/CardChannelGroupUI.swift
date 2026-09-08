//
//  CardChannelGroupUI.swift
//  XenditComponents
//
//  Created by Ahmad X on 16/06/2026.
//

import SwiftUI

struct CardChannelGroupUI: View {
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
                ChannelInstructionsView(instructions: instructions) {
                    Image("xdt_icon_phone", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 40)
                }
            }
        }
    }
}
