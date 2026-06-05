//
//  AmountFormat.swift
//  XenditComponents
//
//  Created by Ahmad X on 05/06/2026.
//

import Foundation

enum AmountFormat {

    // MARK: - Tables

    // Locale used for number formatting (thousand/decimal separators) per currency.
    // Currencies absent from this map fall back to the device's current locale.
    private static let currencyNumberFormatLocale: [String: String] = [
        "IDR": "id",
        "VND": "vi",
        "BRL": "pt-BR",
        "RUB": "ru",
        "CZK": "cs",
        "RON": "ro",
        "UAH": "uk",
        "CLP": "es-CL",
        "COP": "es-CO",
        "UYU": "es-UY",
        "ARS": "es-AR",
        "INR": "hi-IN",
        "NPR": "hi-IN",
        "LKR": "hi-IN",
        "BDT": "hi-IN"
    ]

    private static let currencySymbols: [String: String] = [
        "USD": "US$",
        "CAD": "CA$",
        "EUR": "€",
        "AFN": "؋",
        "ALL": "Lek",
        "AMD": "֏",
        "ARS": "AR$",
        "AUD": "AU$",
        "AZN": "₼",
        "BAM": "KM",
        "BDT": "৳",
        "BIF": "FBu",
        "BND": "BN$",
        "BOB": "Bs",
        "BRL": "R$",
        "BWP": "P",
        "BYN": "Br",
        "BZD": "BZ$",
        "CDF": "FrCD",
        "CHF": "CHF",
        "CLP": "CL$",
        "CNY": "CN¥",
        "COP": "CO$",
        "CRC": "₡",
        "CVE": "CV$",
        "CZK": "Kč",
        "DJF": "Fdj",
        "DKK": "kr",
        "DOP": "RD$",
        "ERN": "Nfk",
        "ETB": "Br",
        "GBP": "£",
        "GEL": "₾",
        "GHS": "GH₵",
        "GNF": "FG",
        "GTQ": "Q",
        "HKD": "HK$",
        "HNL": "L",
        "HUF": "Ft",
        "IDR": "Rp",
        "ILS": "₪",
        "INR": "₹",
        "IRR": "IRR",
        "ISK": "kr",
        "JMD": "J$",
        "JPY": "￥",
        "KES": "Ksh",
        "KHR": "៛",
        "KMF": "FC",
        "KRW": "₩",
        "KZT": "₸",
        "LKR": "SL Re",
        "MDL": "lei",
        "MGA": "MGA",
        "MKD": "MKD",
        "MMK": "K",
        "MOP": "MOP$",
        "MUR": "₨",
        "MXN": "MXN$",
        "MYR": "RM",
        "MZN": "MTn",
        "NAD": "N$",
        "NGN": "₦",
        "NIO": "C$",
        "NOK": "kr",
        "NPR": "रु",
        "NZD": "NZ$",
        "PAB": "B/.",
        "PEN": "S/.",
        "PHP": "₱",
        "PKR": "₨",
        "PLN": "zł",
        "PYG": "₲",
        "RON": "RON",
        "RSD": "RSD",
        "RUB": "₽",
        "RWF": "FR",
        "SDG": "SDG",
        "SEK": "kr",
        "SGD": "S$",
        "SOS": "Ssh",
        "THB": "฿",
        "TOP": "T$",
        "TRY": "TL",
        "TTD": "TT$",
        "TWD": "NT$",
        "TZS": "TSh",
        "UAH": "₴",
        "UGX": "USh",
        "UYU": "$U",
        "UZS": "сум",
        "VND": "₫",
        "XAF": "FCFA",
        "XOF": "CFA",
        "ZAR": "R",
        "ZMW": "K",
        "ZWL": "ZWL$"
    ]

    // Currencies whose symbol follows the amount. Default (absent from map) is "{sym}{amt}".
    private static let currencySymbolPosition: [String: String] = [
        "ALL": "{amt} {sym}",
        "BAM": "{amt} {sym}",
        "BYN": "{amt} {sym}",
        "CZK": "{amt} {sym}",
        "DKK": "{amt} {sym}",
        "GEL": "{amt} {sym}",
        "HUF": "{amt} {sym}",
        "ISK": "{amt} {sym}",
        "IRR": "{amt} {sym}",
        "KHR": "{amt}{sym}",
        "MDL": "{amt} {sym}",
        "MKD": "{amt} {sym}",
        "NOK": "{amt} {sym}",
        "PLN": "{amt} {sym}",
        "RON": "{amt} {sym}",
        "RSD": "{amt} {sym}",
        "RUB": "{amt}{sym}",
        "SEK": "{amt} {sym}",
        "UZS": "{amt} {sym}",
        "VND": "{amt}{sym}"
    ]

    // Currencies that use 3 decimal places. All others default to 2.
    private static let currencyDecimalPlaces: [String: Int] = [
        "BHD": 3,
        "JOD": 3,
        "KWD": 3,
        "LYD": 3,
        "OMR": 3,
        "TND": 3
    ]

    // MARK: - Public API

    static func symbol(for currency: String?) -> String {
        let code = normalise(currency)
        guard !code.isEmpty else { return "" }
        return currencySymbols[code] ?? code
    }

    static func format(amount: Decimal?, currency: String?) -> String {
        let code = normalise(currency)
        guard let amount, !code.isEmpty else { return "" }
        return formatInternal(amount: amount, currencyCode: code)
    }

    static func format(amount: Int?, currency: String?) -> String {
        guard let amount else { return "" }
        return format(amount: Decimal(amount), currency: currency)
    }

    // MARK: - Private

    private static func normalise(_ currency: String?) -> String {
        currency?.trimmingCharacters(in: .whitespaces).uppercased() ?? ""
    }

    private static func formatInternal(amount: Decimal, currencyCode: String) -> String {
        let isNegative = amount < 0
        let absAmount = abs(amount)
        let decimals = currencyDecimalPlaces[currencyCode] ?? 2

        let locale: Locale
        if let tag = currencyNumberFormatLocale[currencyCode] {
            locale = Locale(identifier: tag)
        } else {
            locale = Locale.current
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = 20

        var str = formatter.string(from: NSDecimalNumber(decimal: absAmount)) ?? "\(absAmount)"

        // Strip trailing all-zero decimal part (.00, .000 / ,00, ,000)
        if let range = str.range(of: "[.,]000?$", options: .regularExpression) {
            str.removeSubrange(range)
        }

        let formatted: String
        if let symbol = currencySymbols[currencyCode] {
            let pattern = currencySymbolPosition[currencyCode] ?? "{sym}{amt}"
            formatted = pattern
                .replacingOccurrences(of: "{sym}", with: symbol)
                .replacingOccurrences(of: "{amt}", with: str)
        } else {
            formatted = "\(currencyCode) \(str)"
        }

        return isNegative ? "-\(formatted)" : formatted
    }
}
