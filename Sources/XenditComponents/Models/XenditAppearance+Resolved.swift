//
//  XenditAppearance+Resolved.swift
//  XenditComponents
//
//  Created by Ahmad X on 02/05/2026.
//

import SwiftUI
import UIKit

// MARK: - Resolved SwiftUI Colors

/// Computed properties that map each optional `UIColor` in `XenditAppearance` to a
/// SwiftUI `Color`, falling back to the SDK's semantic design-system color when the
/// merchant has not provided a custom value.
///
/// All views must use these instead of the raw `colorX.map(Color.init) ?? …` pattern
/// so that fallback values are defined in exactly one place.
extension XenditAppearance {

    /// Primary brand / CTA color. Fallback: `Color.Button.primary` (#1762EE).
    var resolvedPrimary: Color { colorPrimary.map(Color.init) ?? .Button.primary }

    /// Main body text. Fallback: `Color.Text.default` (#252525 / #F5F5F5 dark).
    var resolvedText: Color { colorText.map(Color.init) ?? .Text.default }

    /// Supporting / secondary text. Fallback: `Color.Text.secondary` (#585858 / #CACACA dark).
    var resolvedTextSecondary: Color { colorTextSecondary.map(Color.init) ?? .Text.secondary }

    /// Placeholder text inside input fields. Fallback: `Color.Text.placeholder` (#7D7D7D / #868686 dark).
    var resolvedTextPlaceholder: Color { colorTextPlaceholder.map(Color.init) ?? .Text.placeholder }

    /// Background of disabled interactive elements (buttons, search bars).
    /// Fallback: `Color.Surface.disabled` (#F7F7F7 / #222222 dark).
    var resolvedDisabled: Color { colorDisabled.map(Color.init) ?? .Button.disable   }

    /// Error / destructive state. Fallback: `Color.Feedback.danger` (#D1414D).
    var resolvedDanger: Color { colorDanger.map(Color.init) ?? .Feedback.danger }

    /// Field outlines and dividers. Fallback: `Color.Border.default` (#E6E6E6 / 10% white dark).
    var resolvedBorder: Color { colorBorder.map(Color.init) ?? .Border.default }

    /// Page / sheet background. Fallback: `Color.Surface.default` (#FFFFFF / 35% black dark).
    var resolvedBackground: Color { colorBackground.map(Color.init) ?? .Surface.default }

    /// Background of the container box displayed behind QR code images.
    /// Note: `qrForegroundColor` (dot color) cannot be applied because the QR image
    /// is fetched as a pre-rendered bitmap from the Xendit API.
    /// Fallback: `.white`.
    var resolvedQrBackground: Color { qrBackgroundColor.map(Color.init) ?? .white }

    /// Corner radius for buttons, field borders, and grouped cards.
    /// Fallback: `CornerRadius.md` (12 pt).
    var resolvedRadius: CGFloat { borderRadius ?? CornerRadius.md }
}

// MARK: - Resolved UIColor (for UIKit layers)

extension XenditAppearance {

    /// UIColor equivalent of `resolvedTextPlaceholder` — used for `attributedPlaceholder`
    /// inside `XenditTextField`.
    var resolvedPlaceholderUIColor: UIColor {
        colorTextPlaceholder ?? UIColor.placeholderText
    }
}
