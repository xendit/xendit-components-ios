//
//  XenditAppearance.swift
//  XenditComponents
//
//  Created by Ahmad X on 02/05/2026.
//

import SwiftUI
import UIKit

/// Per-weight custom fonts for the Xendit Components SDK.
///
/// Provide only the variants you want to override; any `nil` variant falls back to the
/// SDK's bundled Inter font at the same weight.
public struct XenditFontFamily {
    public var regular:  UIFont?
    public var medium:   UIFont?
    public var semiBold: UIFont?
    public var bold:     UIFont?

    public init(
        regular:  UIFont? = nil,
        medium:   UIFont? = nil,
        semiBold: UIFont? = nil,
        bold:     UIFont? = nil
    ) {
        self.regular  = regular
        self.medium   = medium
        self.semiBold = semiBold
        self.bold     = bold
    }
}

/// Configuration for the visual appearance of the Xendit Components SDK.
public struct XenditAppearance {
    public var fontFamily:            XenditFontFamily?
    public var colorPrimary:          UIColor?
    public var colorText:             UIColor?
    public var colorTextSecondary:    UIColor?
    public var colorTextPlaceholder:  UIColor?
    public var colorDisabled:         UIColor?
    public var colorDanger:           UIColor?
    public var colorBorder:           UIColor?
    public var colorBackground:       UIColor?
    /// Tint color for QR code dots. Note: the QR image is a pre-rendered bitmap fetched from
    /// the Xendit API, so this color cannot affect the dot pixels. Use `qrBackgroundColor`
    /// to customize the container box shown behind the image.
    public var qrForegroundColor:     UIColor?
    /// Background color of the container box rendered behind the QR code image.
    public var qrBackgroundColor:     UIColor?
    public var borderRadius:          CGFloat?
    /// Custom view shown during loading. Defaults to a standard `ProgressView` when `nil`.
    public var customLoadingView:     AnyView?

    public init(
        fontFamily: XenditFontFamily? = nil,
        colorPrimary: UIColor? = nil,
        colorText: UIColor? = nil,
        colorTextSecondary: UIColor? = nil,
        colorTextPlaceholder: UIColor? = nil,
        colorDisabled: UIColor? = nil,
        colorDanger: UIColor? = nil,
        colorBorder: UIColor? = nil,
        colorBackground: UIColor? = nil,
        qrForegroundColor: UIColor? = nil,
        qrBackgroundColor: UIColor? = nil,
        borderRadius: CGFloat? = nil,
        customLoadingView: AnyView? = nil
    ) {
        self.fontFamily = fontFamily
        self.colorPrimary = colorPrimary
        self.colorText = colorText
        self.colorTextSecondary = colorTextSecondary
        self.colorTextPlaceholder = colorTextPlaceholder
        self.colorDisabled = colorDisabled
        self.colorDanger = colorDanger
        self.colorBorder = colorBorder
        self.colorBackground = colorBackground
        self.qrForegroundColor = qrForegroundColor
        self.qrBackgroundColor = qrBackgroundColor
        self.borderRadius = borderRadius
        self.customLoadingView = customLoadingView
    }

}
