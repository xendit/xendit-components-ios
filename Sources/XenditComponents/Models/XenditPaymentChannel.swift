//
//  XenditPaymentChannel.swift
//  XenditComponents
//
//  Created by Ahmad X on 28/04/2026.
//

import Foundation

/// Represents a payment channel available for use in a session.
public struct XenditPaymentChannel: Identifiable {
    public var id: String { primaryChannelCode() }

    /// The channel code(s). Some channels (e.g. GOPAY) have two codes for pay vs. pay-and-save.
    public let channelCode: ChannelCode

    /// Display name of the payment channel.
    public let brandName: String

    /// Theme color in hex format (e.g. "#FF5733").
    public let brandColor: String

    /// Logo URL for the payment channel.
    public let brandLogoUrl: String

    /// UI group to which this channel belongs.
    public let uiGroup: XenditPaymentChannelGroup?

    /// Minimum payment amount for this channel.
    public let minAmount: Double?

    /// Maximum payment amount for this channel.
    public let maxAmount: Double?

    /// Supported card brands (only for card channels).
    public let cardBrands: [CardBrand]?

    public enum ChannelCode {
        case single(String)
        case multiple([String])
    }

    public struct CardBrand {
        public let name: String
        public let logoUrl: String
    }

    func primaryChannelCode() -> String {
        switch channelCode {
        case .single(let code): return code
        case .multiple(let codes): return codes[0]
        }
    }

    func allChannelCodes() -> [String] {
        switch channelCode {
        case .single(let code): return [code]
        case .multiple(let codes): return codes
        }
    }
}

/// A group of payment channels displayed together in the UI.
public struct XenditPaymentChannelGroup: Identifiable {
    public let groupId: String
    public var id: String { groupId }

    /// Display name of the group.
    public let label: String

    /// Icon URL for the group.
    public let iconUrl: String

    /// Channels belonging to this group.
    public let channels: [XenditPaymentChannel]
}
