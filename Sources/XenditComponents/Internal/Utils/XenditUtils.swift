//
//  XenditUtils.swift
//  XenditComponents
//
//  Created by Ahmad X on 05/04/2026.
//

import Foundation

protocol SnakeCaseEncodable: Encodable {}

extension SnakeCaseEncodable {
    func toDictionary() -> [String: Any]? {
        let encoder = JSONEncoder()
        // Use default keys because already handled mapping in the struct
        encoder.keyEncodingStrategy = .useDefaultKeys
        
        guard let data = try? encoder.encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
}
