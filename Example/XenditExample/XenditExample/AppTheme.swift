import UIKit
import XenditComponents

enum AppTheme: String, CaseIterable {
    case `default`  = "Default"
    case dailyBrew  = "Daily Brew"
    case fintechBlue = "Fintech Blue"
    case arcade     = "The Arcade"
    case boutique   = "The Boutique"

    var appearance: XenditAppearance {
        switch self {
        case .default:
            return XenditAppearance()

        case .dailyBrew:
            return XenditAppearance(
                fontFamily: XenditFontFamily(
                    regular:  OpenSansFont.regular,
                    medium:   OpenSansFont.medium,
                    semiBold: OpenSansFont.semiBold,
                    bold:     OpenSansFont.bold
                ),
                colorPrimary:         UIColor(rgb: 0x8D6E63),
                colorText:            UIColor(rgb: 0x3E2723),
                colorTextSecondary:   UIColor(rgb: 0x795548),
                colorTextPlaceholder: UIColor(rgb: 0xA1887F),
                colorDanger:          UIColor(rgb: 0xD32F2F),
                colorBorder:          UIColor(rgb: 0xD7CCC8),
                colorBackground:      UIColor(rgb: 0xFFFBF0),
                borderRadius:         12
            )

        case .fintechBlue:
            return XenditAppearance(
                fontFamily: XenditFontFamily(
                    regular:  OpenSansFont.regular,
                    medium:   OpenSansFont.medium,
                    semiBold: OpenSansFont.semiBold,
                    bold:     OpenSansFont.bold
                ),
                colorPrimary:         UIColor(rgb: 0x0052FF),
                colorText:            UIColor(rgb: 0x111827),
                colorTextSecondary:   UIColor(rgb: 0x6B7280),
                colorTextPlaceholder: UIColor(rgb: 0x9CA3AF),
                colorDanger:          UIColor(rgb: 0xDC2626),
                colorBorder:          UIColor(rgb: 0xE5E7EB),
                colorBackground:      UIColor(rgb: 0xFFFFFF),
                borderRadius:         6
            )

        case .arcade:
            return XenditAppearance(
                fontFamily: XenditFontFamily(
                    regular:  SpaceMonoFont.regular,
                    medium:   SpaceMonoFont.regular,
                    semiBold: SpaceMonoFont.bold,
                    bold:     SpaceMonoFont.bold
                ),
                colorPrimary:         UIColor(rgb: 0x00FFD1),
                colorText:            UIColor(rgb: 0xFFFFFF),
                colorTextSecondary:   UIColor(rgb: 0x888888),
                colorTextPlaceholder: UIColor(rgb: 0x333333),
                colorDisabled:        UIColor(rgb: 0x1A1A1A),
                colorDanger:          UIColor(rgb: 0xFF0055),
                colorBorder:          UIColor(rgb: 0x00FFD1),
                colorBackground:      UIColor(rgb: 0x000000),
                qrForegroundColor:    UIColor(rgb: 0x000000),
                qrBackgroundColor:    UIColor(rgb: 0x00FFD1),
                borderRadius:         4
            )

        case .boutique:
            return XenditAppearance(
                fontFamily: XenditFontFamily(
                    regular:  NotoSerifFont.regular,
                    medium:   NotoSerifFont.medium,
                    semiBold: NotoSerifFont.semiBold,
                    bold:     NotoSerifFont.bold
                ),
                colorPrimary:         UIColor(rgb: 0x2C2C2C),
                colorText:            UIColor(rgb: 0x2C2C2C),
                colorTextSecondary:   UIColor(rgb: 0x5A5A5A),
                colorTextPlaceholder: UIColor(rgb: 0xAAAAAA),
                colorDanger:          UIColor(rgb: 0x941B1B),
                colorBorder:          UIColor(rgb: 0x2C2C2C),
                colorBackground:      UIColor(rgb: 0xF4F1EA),
                qrForegroundColor:    UIColor(rgb: 0x2C2C2C),
                qrBackgroundColor:    UIColor(rgb: 0xF4F1EA),
                borderRadius:         0
            )
        }
    }
}

private extension UIColor {
    convenience init(rgb: UInt32) {
        self.init(
            red:   CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >>  8) & 0xFF) / 255,
            blue:  CGFloat( rgb        & 0xFF) / 255,
            alpha: 1
        )
    }
}
