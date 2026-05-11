//
//  InterFont.swift
//  XenditComponents
//
//  Created by Ahmad X on 02/05/2026.
//

import CoreText
import SwiftUI

public typealias InterFont = Font

public extension InterFont {
    /// Registers all bundled Inter .ttf files with CoreText.
    /// Call once at SDK startup before any font is used.
    static func register() {
        let names = ["Inter-Regular", "Inter-Medium", "Inter-SemiBold", "Inter-Bold"]
        for name in names {
            guard let url = Bundle.module.url(forResource: name, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}

// MARK: - Semantic type scale

public extension InterFont {

    // MARK: Display

    static let displayD1 = InterFont.semiBold(40)

    // MARK: Heading

    static let headingH1 = InterFont.semiBold(32)
    static let headingH2 = InterFont.semiBold(24)
    static let headingH3 = InterFont.semiBold(20)
    static let headingH4 = InterFont.semiBold(18)

    // MARK: Subheading

    static let subheadingLg = InterFont.semiBold(16)
    static let subheadingMd = InterFont.semiBold(14)

    // MARK: Body

    static let bodyEmphasized = InterFont.medium(17)
    static let bodyLg = InterFont.regular(16)
    static let bodyMd = InterFont.regular(14)

    // MARK: Caption

    static let captionRegular = InterFont.regular(12)
    static let captionBold    = InterFont.semiBold(12)

    // MARK: Label — Large

    static let labelLgBold     = InterFont.semiBold(16)
    static let labelLgSemiBold = InterFont.medium(16)
    static let labelLgRegular  = InterFont.regular(16)

    // MARK: Label — Medium

    static let labelMdBold     = InterFont.semiBold(14)
    static let labelMdSemiBold = InterFont.medium(14)
    static let labelMdRegular  = InterFont.regular(14)

    // MARK: Label — Small

    static let labelSmBold     = InterFont.semiBold(12)
    static let labelSmSemiBold = InterFont.medium(12)
    static let labelSmRegular  = InterFont.regular(12)

    // MARK: Label — XSmall

    static let labelXsBold     = InterFont.semiBold(10)
    static let labelXsSemiBold = InterFont.medium(10)
    static let labelXsRegular  = InterFont.regular(10)

    // MARK: Balance

    static let balanceLg = InterFont.semiBold(16)
    static let balanceMd = InterFont.semiBold(14)
    static let balanceSm = InterFont.semiBold(12)    
}

// MARK: - Private helpers

private extension InterFont {
    static func regular(_ size: CGFloat) -> Font {
        XenditComponents.appearance.fontFamily?.regular
            .map { Font($0.withSize(size)) }
            ?? .custom("Inter-Regular", size: size)
    }
    static func medium(_ size: CGFloat) -> Font {
        XenditComponents.appearance.fontFamily?.medium
            .map { Font($0.withSize(size)) }
            ?? .custom("Inter-Medium", size: size)
    }
    static func semiBold(_ size: CGFloat) -> Font {
        XenditComponents.appearance.fontFamily?.semiBold
            .map { Font($0.withSize(size)) }
            ?? .custom("Inter-SemiBold", size: size)
    }
    static func bold(_ size: CGFloat) -> Font {
        XenditComponents.appearance.fontFamily?.bold
            .map { Font($0.withSize(size)) }
            ?? .custom("Inter-Bold", size: size)
    }
}
