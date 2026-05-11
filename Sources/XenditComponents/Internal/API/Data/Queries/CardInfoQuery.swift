//
//  CardInfoQuery.swift
//  XenditComponents
//
//  Created by Ahmad X on 05/04/2026.
//

import Foundation

struct CardInfoQuery {
    let cardNumber: String
    
    var json: [String: Any] {
        ["card_number": cardNumber]
    }
    
    init(cardNumber: String) {
        self.cardNumber = cardNumber
    }
}
