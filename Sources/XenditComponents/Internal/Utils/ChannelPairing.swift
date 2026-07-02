//
//  ChannelPairing.swift
//  XenditComponents
//
//  Created by Ahmad X on 15/06/2026.
//

import Foundation

struct ChannelVariants {
    let saveChannel: SessionResponse.Channel
    let nonSaveChannel: SessionResponse.Channel
}

struct CombinedChannelsResult {
    let channels: [SessionResponse.Channel]
    let variants: [String: ChannelVariants]
}

extension CombinedChannelsResult {
    /// Collapses save/non-save channel pairs into a single display entry.
    ///
    /// When the backend returns two channels for the same brand that differ only in `allowSave`,
    /// this function merges them: the non-save channel is used as the display entry and the save
    /// channel is stored in `variants`, keyed by the non-save channel's `channelCode`.
    ///
    /// At submission time, resolve the effective channel from `variants` based on the user's
    /// save preference before calling `performSubmission`.
    static func combining(_ channels: [SessionResponse.Channel]?) -> CombinedChannelsResult {
        guard let channels = channels, !channels.isEmpty else {
            return CombinedChannelsResult(channels: [], variants: [:])
        }

        struct CombineKey: Hashable {
            let uiGroup: String
            let brandName: String
            let pmType: String
            let requiresCustomerDetails: Bool?

            func hash(into hasher: inout Hasher) {
                hasher.combine(uiGroup)
                hasher.combine(brandName)
                hasher.combine(pmType)
                hasher.combine(requiresCustomerDetails)
            }

            static func == (lhs: CombineKey, rhs: CombineKey) -> Bool {
                lhs.uiGroup == rhs.uiGroup &&
                lhs.brandName == rhs.brandName &&
                lhs.pmType == rhs.pmType &&
                lhs.requiresCustomerDetails == rhs.requiresCustomerDetails
            }
        }

        func key(for channel: SessionResponse.Channel) -> CombineKey {
            CombineKey(
                uiGroup: channel.uiGroup,
                brandName: channel.brandName,
                pmType: channel.pmType?.rawValue ?? "",
                requiresCustomerDetails: channel.requiresCustomerDetails
            )
        }

        let grouped = Dictionary(grouping: channels, by: key(for:))

        let pairsByKey: [CombineKey: ChannelVariants] = grouped.reduce(into: [:]) { result, entry in
            let (k, group) = entry
            guard group.count == 2,
                  let save    = group.first(where: {  $0.allowSave }),
                  let nonSave = group.first(where: { !$0.allowSave })
            else { return }
            result[k] = ChannelVariants(saveChannel: save, nonSaveChannel: nonSave)
        }

        var combined: [SessionResponse.Channel] = []
        var variants: [String: ChannelVariants] = [:]
        var addedCodes = Set<String>()

        for channel in channels {
            if let pair = pairsByKey[key(for: channel)] {
                let displayCode = pair.nonSaveChannel.channelCode
                if addedCodes.insert(displayCode).inserted {
                    combined.append(pair.nonSaveChannel)
                    variants[displayCode] = pair
                }
            } else {
                combined.append(channel)
            }
        }

        return CombinedChannelsResult(channels: combined, variants: variants)
    }
}
