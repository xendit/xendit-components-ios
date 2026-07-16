//
//  AmountFormatTests.swift
//  XenditComponents
//
//  Created by Ahmad X on 05/06/2026.
//

import XCTest
@testable import XenditComponents

final class AmountFormatTests: XCTestCase {

    // MARK: - symbol(for:)

    func testSymbolKnownCurrencies() {
        XCTAssertEqual(AmountFormat.symbol(for: "IDR"), "Rp")
        XCTAssertEqual(AmountFormat.symbol(for: "USD"), "US$")
        XCTAssertEqual(AmountFormat.symbol(for: "EUR"), "€")
        XCTAssertEqual(AmountFormat.symbol(for: "GBP"), "£")
        XCTAssertEqual(AmountFormat.symbol(for: "VND"), "₫")
        XCTAssertEqual(AmountFormat.symbol(for: "THB"), "฿")
        XCTAssertEqual(AmountFormat.symbol(for: "PHP"), "₱")
        XCTAssertEqual(AmountFormat.symbol(for: "MYR"), "RM")
        XCTAssertEqual(AmountFormat.symbol(for: "SGD"), "S$")
    }

    func testSymbolUnknownCurrencyReturnsCode() {
        XCTAssertEqual(AmountFormat.symbol(for: "XYZ"), "XYZ")
        XCTAssertEqual(AmountFormat.symbol(for: "ABC"), "ABC")
    }

    func testSymbolCaseInsensitive() {
        XCTAssertEqual(AmountFormat.symbol(for: "idr"), "Rp")
        XCTAssertEqual(AmountFormat.symbol(for: "Usd"), "US$")
    }

    func testSymbolNilOrEmptyReturnsEmpty() {
        XCTAssertEqual(AmountFormat.symbol(for: nil), "")
        XCTAssertEqual(AmountFormat.symbol(for: ""), "")
        XCTAssertEqual(AmountFormat.symbol(for: "   "), "")
    }

    // MARK: - format(amount: Decimal?, currency:) — symbol prefix (default)

    func testFormatUSD() {
        XCTAssertEqual(AmountFormat.format(amount: 1000.0 as Decimal, currency: "USD"), "US$1,000")
        XCTAssertEqual(AmountFormat.format(amount: 1000.50 as Decimal, currency: "USD"), "US$1,000.50")
        XCTAssertEqual(AmountFormat.format(amount: 0.99 as Decimal, currency: "USD"), "US$0.99")
    }

    func testFormatIDR() {
        // IDR uses Indonesian locale (id): thousand separator = ".", decimal separator = ","
        XCTAssertEqual(AmountFormat.format(amount: 50000 as Decimal, currency: "IDR"), "Rp50.000")
        XCTAssertEqual(AmountFormat.format(amount: 1000000 as Decimal, currency: "IDR"), "Rp1.000.000")
    }

    func testFormatEUR() {
        XCTAssertEqual(AmountFormat.format(amount: 99.99 as Decimal, currency: "EUR"), "€99.99")
        XCTAssertEqual(AmountFormat.format(amount: 1000 as Decimal, currency: "EUR"), "€1,000")
    }

    // MARK: - format — symbol suffix currencies

    func testFormatVND() {
        // VND: {amt}{sym}, Vietnamese locale
        let result = AmountFormat.format(amount: 100000 as Decimal, currency: "VND")
        XCTAssertTrue(result.hasSuffix("₫"), "VND should end with ₫, got: \(result)")
        XCTAssertFalse(result.hasPrefix("₫"), "VND should not start with ₫")
    }

    func testFormatRUB() {
        // RUB: {amt}{sym}
        let result = AmountFormat.format(amount: 5000 as Decimal, currency: "RUB")
        XCTAssertTrue(result.hasSuffix("₽"), "RUB should end with ₽, got: \(result)")
    }

    func testFormatPLN() {
        // PLN: {amt} {sym}
        let result = AmountFormat.format(amount: 250 as Decimal, currency: "PLN")
        XCTAssertTrue(result.hasSuffix(" zł"), "PLN should end with ' zł', got: \(result)")
    }

    // MARK: - format — 3-decimal currencies

    func testFormatKWD() {
        // KWD has 3 decimal places, all shown (minimumFractionDigits = currency decimals)
        let result = AmountFormat.format(amount: Decimal(string: "10.500")!, currency: "KWD")
        XCTAssertEqual(result, "KWD 10.500")
    }

    func testFormatBHD() {
        let result = AmountFormat.format(amount: Decimal(string: "5.123")!, currency: "BHD")
        XCTAssertEqual(result, "BHD 5.123")
    }

    func testFormatKWDWholeNumber() {
        // Whole amount: .000 trailing zeros should be stripped
        let result = AmountFormat.format(amount: 10 as Decimal, currency: "KWD")
        XCTAssertEqual(result, "KWD 10")
    }

    // MARK: - format — trailing zero stripping

    func testTrailingZerosStripped() {
        XCTAssertEqual(AmountFormat.format(amount: 100 as Decimal, currency: "USD"), "US$100")
        XCTAssertEqual(AmountFormat.format(amount: 50000 as Decimal, currency: "IDR"), "Rp50.000")
    }

    func testNonZeroDecimalsPreserved() {
        XCTAssertEqual(AmountFormat.format(amount: Decimal(string: "99.50")!, currency: "USD"), "US$99.50")
        XCTAssertEqual(AmountFormat.format(amount: Decimal(string: "1.05")!, currency: "USD"), "US$1.05")
    }

    // MARK: - format — Decimal precision (no floating-point drift)

    func testDecimalPrecisionNoDrift() {
        // 0.1 + 0.2 is infamously imprecise in Double (0.30000000000000004)
        let a: Decimal = 0.1
        let b: Decimal = 0.2
        XCTAssertEqual(AmountFormat.format(amount: a + b, currency: "USD"), "US$0.30")
    }

    // MARK: - format — negative amounts

    func testFormatNegativeAmount() {
        XCTAssertEqual(AmountFormat.format(amount: -500 as Decimal, currency: "USD"), "-US$500")
        XCTAssertEqual(AmountFormat.format(amount: Decimal(string: "-1234.50")!, currency: "USD"), "-US$1,234.50")
    }

    func testFormatNegativeIDR() {
        let result = AmountFormat.format(amount: -75000 as Decimal, currency: "IDR")
        XCTAssertTrue(result.hasPrefix("-"), "Negative IDR should start with -, got: \(result)")
        XCTAssertTrue(result.contains("Rp"), "Negative IDR should contain Rp, got: \(result)")
    }

    // MARK: - format — unknown currency falls back to "CODE amount"

    func testFormatUnknownCurrency() {
        let result = AmountFormat.format(amount: 123 as Decimal, currency: "XYZ")
        XCTAssertTrue(result.hasPrefix("XYZ "), "Unknown currency should start with code, got: \(result)")
    }

    // MARK: - format — nil / empty guards

    func testFormatNilAmountReturnsEmpty() {
        XCTAssertEqual(AmountFormat.format(amount: nil as Decimal?, currency: "USD"), "")
    }

    func testFormatNilCurrencyReturnsEmpty() {
        XCTAssertEqual(AmountFormat.format(amount: 100 as Decimal, currency: nil), "")
    }

    func testFormatEmptyCurrencyReturnsEmpty() {
        XCTAssertEqual(AmountFormat.format(amount: 100 as Decimal, currency: ""), "")
    }

    // MARK: - format(amount: Int?, currency:)

    func testFormatIntAmount() {
        XCTAssertEqual(AmountFormat.format(amount: 1000, currency: "USD"), "US$1,000")
    }

    func testFormatIntNilReturnsEmpty() {
        XCTAssertEqual(AmountFormat.format(amount: nil as Int?, currency: "USD"), "")
    }

    // MARK: - format — case insensitive currency input

    func testFormatCaseInsensitiveCurrency() {
        XCTAssertEqual(
            AmountFormat.format(amount: 100 as Decimal, currency: "usd"),
            AmountFormat.format(amount: 100 as Decimal, currency: "USD")
        )
        XCTAssertEqual(
            AmountFormat.format(amount: 100 as Decimal, currency: "Idr"),
            AmountFormat.format(amount: 100 as Decimal, currency: "IDR")
        )
    }
}
