//
//  XDTAppearance.swift
//  XenditComponents
//
//  Created by Ahmad X on 03/05/2026.
//

import UIKit

// MARK: - XDTFontFamily

/// Objective-C compatible wrapper for `XenditFontFamily`.
///
/// Provide only the variants you want to override; any `nil` variant falls back to the
/// SDK's bundled Inter font at that weight.
///
/// ```objc
/// XDTFontFamily *fonts = [XDTFontFamily new];
/// fonts.regular  = [UIFont fontWithName:@"MyFont-Regular"  size:14];
/// fonts.semiBold = [UIFont fontWithName:@"MyFont-SemiBold" size:14];
/// // medium and bold will use the SDK default (Inter)
/// ```
@objc(XDTFontFamily)
public final class XDTFontFamily: NSObject {

    /// Font used for regular-weight text.
    @objc public var regular:  UIFont?
    /// Font used for medium-weight text.
    @objc public var medium:   UIFont?
    /// Font used for semi-bold-weight text.
    @objc public var semiBold: UIFont?
    /// Font used for bold-weight text.
    @objc public var bold:     UIFont?

    @objc public override init() { super.init() }

    // MARK: Internal Swift conversion

    func toSwift() -> XenditFontFamily {
        XenditFontFamily(regular: regular, medium: medium, semiBold: semiBold, bold: bold)
    }

    convenience init(swiftFamily: XenditFontFamily) {
        self.init()
        regular  = swiftFamily.regular
        medium   = swiftFamily.medium
        semiBold = swiftFamily.semiBold
        bold     = swiftFamily.bold
    }
}

// MARK: - XDTAppearance

/// Objective-C compatible wrapper for `XenditAppearance`.
///
/// Set any property you want to override; leave others as `nil` (or `XDTAppearance.noOverride`
/// for `borderRadius`) to use the SDK's design-system defaults.
///
/// Note: `customLoadingView` (`SwiftUI.AnyView`) cannot be represented in Objective-C.
/// To supply a custom loading indicator, use `XenditAppearance` from Swift instead.
///
/// ```objc
/// XDTAppearance *appearance = [XDTAppearance new];
/// appearance.fontFamily    = myFontFamily;
/// appearance.colorPrimary  = [UIColor colorWithRed:0.09 green:0.38 blue:0.93 alpha:1];
/// appearance.colorDanger   = UIColor.systemRedColor;
/// appearance.borderRadius  = 12;
/// [XDTComponents initializeWithAppearance:appearance];
/// ```
@objc(XDTAppearance)
public final class XDTAppearance: NSObject {

    // MARK: - Font

    /// Per-weight custom font variants. `nil` uses the SDK's bundled Inter font throughout.
    @objc public var fontFamily: XDTFontFamily?

    // MARK: - Colors

    /// Primary brand / CTA color (buttons, selected states, checkmarks).
    @objc public var colorPrimary: UIColor?

    /// Main body text color.
    @objc public var colorText: UIColor?

    /// Supporting / secondary text color (subtitles, captions).
    @objc public var colorTextSecondary: UIColor?

    /// Placeholder text color inside input fields.
    @objc public var colorTextPlaceholder: UIColor?

    /// Background color of disabled interactive elements (buttons, search bars).
    @objc public var colorDisabled: UIColor?

    /// Error / destructive state color (field borders, error messages).
    @objc public var colorDanger: UIColor?

    /// Field outline and divider color.
    @objc public var colorBorder: UIColor?

    /// Page and sheet background color.
    @objc public var colorBackground: UIColor?

    /// Tint for QR code dots.
    /// Note: the QR image is a pre-rendered bitmap fetched from the Xendit API; this color
    /// does not affect the dot pixels. Use `qrBackgroundColor` for the container box.
    @objc public var qrForegroundColor: UIColor?

    /// Background color of the container box rendered behind the QR code image.
    @objc public var qrBackgroundColor: UIColor?

    // MARK: - Layout

    /// Corner radius (pt) applied to buttons, field borders, and grouped cards.
    ///
    /// Set to `XDTAppearance.noOverride` (the default) to let the SDK use its built-in value
    /// (12 pt). Any non-negative value overrides it.
    @objc public var borderRadius: CGFloat = XDTAppearance.noOverride

    /// Pass as `borderRadius` to tell the SDK to use its built-in corner radius (12 pt).
    @objc public static let noOverride: CGFloat = -1

    // MARK: - Init

    @objc public override init() { super.init() }

    // MARK: - Internal Swift conversion

    func toSwift() -> XenditAppearance {
        XenditAppearance(
            fontFamily:           fontFamily?.toSwift(),
            colorPrimary:         colorPrimary,
            colorText:            colorText,
            colorTextSecondary:   colorTextSecondary,
            colorTextPlaceholder: colorTextPlaceholder,
            colorDisabled:        colorDisabled,
            colorDanger:          colorDanger,
            colorBorder:          colorBorder,
            colorBackground:      colorBackground,
            qrForegroundColor:    qrForegroundColor,
            qrBackgroundColor:    qrBackgroundColor,
            borderRadius:         borderRadius >= 0 ? borderRadius : nil
            // customLoadingView is intentionally omitted — not ObjC-bridgeable
        )
    }

    convenience init(swiftAppearance s: XenditAppearance) {
        self.init()
        fontFamily           = s.fontFamily.map { XDTFontFamily(swiftFamily: $0) }
        colorPrimary         = s.colorPrimary
        colorText            = s.colorText
        colorTextSecondary   = s.colorTextSecondary
        colorTextPlaceholder = s.colorTextPlaceholder
        colorDisabled        = s.colorDisabled
        colorDanger          = s.colorDanger
        colorBorder          = s.colorBorder
        colorBackground      = s.colorBackground
        qrForegroundColor    = s.qrForegroundColor
        qrBackgroundColor    = s.qrBackgroundColor
        borderRadius         = s.borderRadius ?? XDTAppearance.noOverride
    }
}
