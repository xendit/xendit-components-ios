import CoreText
import UIKit

enum OpenSansFont {

    static func register() {
        let names = [
            "OpenSans-Regular",
            "OpenSans-Medium",
            "OpenSans-SemiBold",
            "OpenSans-Bold",
        ]
        for name in names {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                print("[XenditExampleUIKit] '\(name).ttf' not found in bundle — add it to Copy Bundle Resources in Xcode.")
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    static var regular:  UIFont { UIFont(name: "OpenSans-Regular",  size: 14) ?? .systemFont(ofSize: 14, weight: .regular) }
    static var medium:   UIFont { UIFont(name: "OpenSans-Medium",   size: 14) ?? .systemFont(ofSize: 14, weight: .medium) }
    static var semiBold: UIFont { UIFont(name: "OpenSans-SemiBold", size: 14) ?? .systemFont(ofSize: 14, weight: .semibold) }
    static var bold:     UIFont { UIFont(name: "OpenSans-Bold",     size: 14) ?? .systemFont(ofSize: 14, weight: .bold) }
}
