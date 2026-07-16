//
//  QrNmidSearcherUtil.swift
//  XenditComponents
//
//  Created by Ahmad X on 29/05/2026.
//

import Foundation

/// Parses a QRIS data string (EMV tag-length-value format) to extract the
/// National Merchant ID (NMID) from the merchant account info block.
struct QrNmidSearcherUtil {
    static func getNationalMerchantID(from qrisData: String) -> String? {
        let clean = qrisData.filter { !$0.isWhitespace }
        for tag in 26...51 {
            let tagStr = String(format: "%02d", tag)
            guard let merchantInfo = value(in: clean, forTag: tagStr) else { continue }
            if value(in: merchantInfo, forTag: "00") == "ID.CO.QRIS.WWW",
               let nmid = value(in: merchantInfo, forTag: "02") {
                return nmid
            }
        }
        return nil
    }

    private static func value(in data: String, forTag targetTag: String) -> String? {
        guard data.count >= 4 else { return nil }
        var idx = data.startIndex
        while data.distance(from: idx, to: data.endIndex) >= 4 {
            let tagEnd = data.index(idx, offsetBy: 2)
            let tag = String(data[idx..<tagEnd])
            let lenEnd = data.index(tagEnd, offsetBy: 2)
            guard let length = Int(data[tagEnd..<lenEnd]) else { return nil }
            guard let valEnd = data.index(lenEnd, offsetBy: length, limitedBy: data.endIndex) else { break }
            if tag == targetTag { return String(data[lenEnd..<valEnd]) }
            idx = valEnd
        }
        return nil
    }
}
