//
//  String+Extension.swift
//  XenditComponents
//
//  Created by Ahmad X on 27/04/2026.
//

import Foundation

// MARK: - Decimal

extension String {
    // For decoding. Keep locale constant, since backend is likely keeping the same format regardless of phone's locale
    func decimalValue(_ locale: Locale = Locale(identifier: "en")) -> Decimal? {
        Decimal(string: self, locale: locale)
    }
}
