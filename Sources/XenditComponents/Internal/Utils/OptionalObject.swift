//
//  OptionalObject.swift
//  XenditComponents
//
//  Created by Ahmad X on 07/04/2026.
//

import Foundation

struct OptionalObject<Object: Decodable>: Decodable {
    let value: Object?

    init(from decoder: Decoder) throws {
        value = try? decoder.singleValueContainer().decode(Object.self)
    }
}
