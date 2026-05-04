import CoreText
import UIKit

/// Registers and vends Playfair Display font variants for use with XenditFontFamily.
///
/// Before accessing any font property, call `PlayfairFont.register()` once at app startup.
/// The font files must be added to the Xcode target as bundle resources (Build Phases →
/// Copy Bundle Resources), even though they live in the Fonts/ group.
enum PlayfairFont {

    // MARK: - Registration

    static func register() {
        let names = [
            "PlayfairDisplay-Regular",
            "PlayfairDisplay-Medium",
            "PlayfairDisplay-SemiBold",
            "PlayfairDisplay-Bold",
        ]
        for name in names {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                print("[XenditExampleUIKit] '\(name).ttf' not found in bundle — add it to Copy Bundle Resources in Xcode.")
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    // MARK: - Font vending

    /// Size is arbitrary — XenditFontFamily scales it via `.withSize(_:)` at each usage.
    static var regular:  UIFont { UIFont(name: "PlayfairDisplay-Regular",  size: 14) ?? .systemFont(ofSize: 14, weight: .regular) }
    static var medium:   UIFont { UIFont(name: "PlayfairDisplay-Medium",   size: 14) ?? .systemFont(ofSize: 14, weight: .medium) }
    static var semiBold: UIFont { UIFont(name: "PlayfairDisplay-SemiBold", size: 14) ?? .systemFont(ofSize: 14, weight: .semibold) }
    static var bold:     UIFont { UIFont(name: "PlayfairDisplay-Bold",     size: 14) ?? .systemFont(ofSize: 14, weight: .bold) }
}
