//
//  KeyedDecodingContainer+Core.swift
//  XenditComponents
//
//  Created by Ahmad X on 27/04/2026.
//

import Foundation

extension KeyedDecodingContainer where Key: CodingKey {
    func decodeDecimal(forKey key: KeyedDecodingContainer<K>.Key) throws -> Decimal {
        try decode(Decimal.self, forKey: key)
    }

    // Do not deprecate this, this is used for decoding date with custom date formatter
    func decodeDate(forKey key: KeyedDecodingContainer<K>.Key, dateFormatter: DateFormatter) throws -> Date {
        let string = try decode(String.self, forKey: key)
        if let date = dateFormatter.date(from: string) {
            return date
        } else {
            throw decodingError(string, key: key)
        }
    }

    func decodingError(_ rawValue: String, key: KeyedDecodingContainer<K>.Key) -> DecodingError {
        DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Invalid raw value [\(rawValue)] for key [\(key)]")
    }

    func decode(_ type: Decimal.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> Decimal {
        if let intValue = try? decode(Int.self, forKey: key) {
            return Decimal(intValue)
        } else if let doubleValue = try? decode(Double.self, forKey: key) {
            return Decimal(doubleValue)
        }
        let string = try decode(String.self, forKey: key)
        if let decimalValue = string.decimalValue() {
            return decimalValue
        } else {
            throw decodingError(string, key: key)
        }
    }
}
