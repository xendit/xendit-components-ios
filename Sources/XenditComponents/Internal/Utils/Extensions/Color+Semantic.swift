//
//  Color+Semantic.swift
//  XenditComponents
//
//  Created by Ahmad X on 28/04/2026.
//

import SwiftUI
import UIKit

// MARK: - Primitive hex initializer

private extension UIColor {
    convenience init(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") { hex = String(hex.dropFirst()) }
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        self.init(
            red:   CGFloat((rgb & 0xFF0000) >> 16) / 255,
            green: CGFloat((rgb & 0x00FF00) >>  8) / 255,
            blue:  CGFloat( rgb & 0x0000FF       ) / 255,
            alpha: 1
        )
    }

    static func adaptive(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { $0.userInterfaceStyle == .dark ? dark : light }
    }
}

// MARK: - Semantic colors

extension Color {

    // MARK: Surface

    enum Surface {
        /// Default page / sheet background.
        /// xendit-color-background-default · Light #FFFFFF · Dark #000000 @ 35%
        static var `default`: Color {
            Color(UIColor.adaptive(
                light: UIColor(hex: "#FFFFFF"),
                dark:  UIColor(white: 0, alpha: 0.35)
            ))
        }

        /// Slightly off-white background for recessed areas.
        /// xendit-color-background-weak · Light #FAFAFA · Dark #FFFFFF
        static var weak: Color {
            Color(UIColor.adaptive(
                light: UIColor(hex: "#FAFAFA"),
                dark:  UIColor(hex: "#FFFFFF")
            ))
        }

        /// Website / outer-canvas background.
        /// xendit-color-website · Light #FEFEFC · Dark #17182B
        static var website: Color {
            Color(UIColor.adaptive(
                light: UIColor(hex: "#FEFEFC"),
                dark:  UIColor(hex: "#17182B")
            ))
        }

        /// Background for disabled interactive elements.
        /// xendit-color-disabled · Light #F7F7F7 · Dark #222222
        static var disabled: Color {
            Color(UIColor.adaptive(
                light: UIColor(hex: "#F7F7F7"),
                dark:  UIColor(hex: "#222222")
            ))
        }
    }

    // MARK: Button

    enum Button {
        /// Primary brand / CTA button fill.
        /// xendit-color-primary · Light #1762EE · Dark #1762EE
        static var primary: Color {
            Color(UIColor(hex: "#1762EE"))
        }
        
        static var disable: Color {
            Color(UIColor(hex: "#CFCCCD"))
        }
    }

    // MARK: Text

    enum Text {
        /// Primary text — highest contrast, body copy and labels.
        /// xendit-color-text · Light #252525 · Dark #F5F5F5
        static var `default`: Color {
            Color(UIColor.adaptive(
                light: UIColor(hex: "#252525"),
                dark:  UIColor(hex: "#F5F5F5")
            ))
        }

        /// Secondary / supporting text.
        /// xendit-color-text-secondary · Light #585858 · Dark #CACACA
        static var secondary: Color {
            Color(UIColor.adaptive(
                light: UIColor(hex: "#585858"),
                dark:  UIColor(hex: "#CACACA")
            ))
        }

        /// Placeholder text inside input fields.
        /// xendit-color-text-placeholder · Light #7D7D7D · Dark #868686
        static var placeholder: Color {
            Color(UIColor.adaptive(
                light: UIColor(hex: "#7D7D7D"),
                dark:  UIColor(hex: "#868686")
            ))
        }
    }

    // MARK: Border

    enum Border {
        /// Default divider / field outline.
        /// xendit-color-border · Light #E6E6E6 · Dark #FFFFFF @ 10%
        static var `default`: Color {
            Color(UIColor.adaptive(
                light: UIColor(hex: "#E6E6E6"),
                dark:  UIColor(white: 1, alpha: 0.10)
            ))
        }
    }

    // MARK: Icon

    enum Icon {
        /// Checkmark glyph on filled backgrounds (checkbox, toggle).
        /// xendit-color-icon-checkmark · Light #FFFFFF · Dark #FFFFFF
        static var checkmark: Color {
            Color(UIColor(hex: "#FFFFFF"))
        }
    }

    // MARK: Feedback

    enum Feedback {
        /// Destructive / error state.
        /// xendit-color-danger · Light #D1414D · Dark #D1414D
        static var danger: Color {
            Color(UIColor(hex: "#D1414D"))
        }

        /// Positive / confirmed state.
        /// xendit-color-success · Light #007C5C · Dark #FFFFFF
        static var success: Color {
            Color(UIColor.adaptive(
                light: UIColor(hex: "#007C5C"),
                dark:  UIColor(hex: "#FFFFFF")
            ))
        }

        /// Cautionary / attention state.
        /// xendit-color-warning · Light #EE9F16 · Dark #FFFFFF
        static var warning: Color {
            Color(UIColor.adaptive(
                light: UIColor(hex: "#EE9F16"),
                dark:  UIColor(hex: "#FFFFFF")
            ))
        }
    }
}
