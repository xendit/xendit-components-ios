//
//  Country.swift
//  XenditComponents
//
//  Created by Ahmad X on 01/05/2026.
//

import Foundation
import libPhoneNumber

/// Represents a country with its ISO code, display name, and dial code.
public struct Country: Equatable {
    public let name: String
    public let code: String
    public let dialCode: String

    public var flagUrl: String {
        "https://assets.xendit.co/payment-session/flags/circle/\(code.lowercased()).svg"
    }

    /// All countries supported by libPhoneNumber, sorted by display name.
    /// Region codes and dial codes come from NBPhoneNumberUtil; names from Locale.
    public static let countries: [Country] = {
        let phoneUtil = NBPhoneNumberUtil.sharedInstance()
        guard let regions = phoneUtil?.getSupportedRegions() as? [String] else { return [] }
        return regions.compactMap { code -> Country? in
            guard let name = Locale.current.localizedString(forRegionCode: code),
                  let dialCodeNumber = phoneUtil?.getCountryCode(forRegion: code),
                  dialCodeNumber.intValue > 0
            else { return nil }
            return Country(name: name, code: code, dialCode: dialCodeNumber.stringValue)
        }
        .sorted { $0.name < $1.name }
    }()

    /// Countries sorted longest-dial-code-first so prefix matching is unambiguous (e.g. +1 vs +1 340).
    public static let countriesByDialCodeLength: [Country] = countries.sorted {
        $0.dialCode.count > $1.dialCode.count
    }

    public static func warmUp() {
        _ = countries
    }

    public static func fromCode(_ code: String) -> Country? {
        countries.first { $0.code.uppercased() == code.uppercased() }
    }

    public static func fromDialCode(_ dialCode: String) -> Country? {
        let clean = dialCode.replacingOccurrences(of: "+", with: "")
        return countries.first { $0.dialCode == clean }
    }
}
