//
//  XenditPaymentMethod.swift
//  XenditComponents
//
//  Created by Ahmad X on 16/07/2026.
//

import Foundation

/// Payment method types the merchant can use to filter and order the channel picker.
public enum XenditPaymentMethod {
    case cards
    case ewallet
    case qrCode
    case bankTransfer
    case onlineBanking
    case directDebit
    case virtualAccount
    case overTheCounter
}
