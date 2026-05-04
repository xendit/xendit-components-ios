//
//  InterUIFont.swift
//  XenditComponents
//
//  Created by Ahmad X on 02/05/2026.
//

import UIKit

public typealias InterUIFont = UIFont

// MARK: - Semantic type scale

public extension InterUIFont {

    // MARK: Display

    static let displayD1 = InterUIFont.semiBold(40)

    // MARK: Heading

    static let headingH1 = InterUIFont.semiBold(32)
    static let headingH2 = InterUIFont.semiBold(24)
    static let headingH3 = InterUIFont.semiBold(20)
    static let headingH4 = InterUIFont.semiBold(18)

    // MARK: Subheading

    static let subheadingLg = InterUIFont.semiBold(16)
    static let subheadingMd = InterUIFont.semiBold(14)

    // MARK: Body

    static let bodyLg = InterUIFont.regular(16)
    static let bodyMd = InterUIFont.regular(14)

    // MARK: Caption

    static let captionRegular = InterUIFont.regular(12)
    static let captionBold    = InterUIFont.semiBold(12)

    // MARK: Label — Large

    static let labelLgBold     = InterUIFont.semiBold(16)
    static let labelLgSemiBold = InterUIFont.medium(16)
    static let labelLgRegular  = InterUIFont.regular(16)

    // MARK: Label — Medium

    static let labelMdBold     = InterUIFont.semiBold(14)
    static let labelMdSemiBold = InterUIFont.medium(14)
    static let labelMdRegular  = InterUIFont.regular(14)

    // MARK: Label — Small

    static let labelSmBold     = InterUIFont.semiBold(12)
    static let labelSmSemiBold = InterUIFont.medium(12)
    static let labelSmRegular  = InterUIFont.regular(12)

    // MARK: Label — XSmall

    static let labelXsBold     = InterUIFont.semiBold(10)
    static let labelXsSemiBold = InterUIFont.medium(10)
    static let labelXsRegular  = InterUIFont.regular(10)

    // MARK: Balance

    static let balanceLg = InterUIFont.semiBold(16)
    static let balanceMd = InterUIFont.semiBold(14)
    static let balanceSm = InterUIFont.semiBold(12)
}

// MARK: - Private helpers

private extension InterUIFont {
    static func regular(_ size: CGFloat) -> UIFont {
        XenditComponents.appearance.fontFamily?.regular?.withSize(size)
            ?? make("Inter-Regular", size: size, weight: .regular)
    }
    static func medium(_ size: CGFloat) -> UIFont {
        XenditComponents.appearance.fontFamily?.medium?.withSize(size)
            ?? make("Inter-Medium", size: size, weight: .medium)
    }
    static func semiBold(_ size: CGFloat) -> UIFont {
        XenditComponents.appearance.fontFamily?.semiBold?.withSize(size)
            ?? make("Inter-SemiBold", size: size, weight: .semibold)
    }
    static func bold(_ size: CGFloat) -> UIFont {
        XenditComponents.appearance.fontFamily?.bold?.withSize(size)
            ?? make("Inter-Bold", size: size, weight: .bold)
    }

    static func make(_ name: String, size: CGFloat, weight: UIFont.Weight) -> UIFont {
        UIFont(name: name, size: size) ?? .systemFont(ofSize: size, weight: weight)
    }
}
