import CoreText
import UIKit

enum NotoSerifFont {

    static func register() {
        let names = [
            "NotoSerif-Regular",
            "NotoSerif-Medium",
            "NotoSerif-SemiBold",
            "NotoSerif-Bold",
        ]
        for name in names {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                print("[XenditExampleUIKit] '\(name).ttf' not found in bundle — add it to Copy Bundle Resources in Xcode.")
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    static var regular:  UIFont { UIFont(name: "NotoSerif-Regular",  size: 14) ?? .systemFont(ofSize: 14, weight: .regular) }
    static var medium:   UIFont { UIFont(name: "NotoSerif-Medium",   size: 14) ?? .systemFont(ofSize: 14, weight: .medium) }
    static var semiBold: UIFont { UIFont(name: "NotoSerif-SemiBold", size: 14) ?? .systemFont(ofSize: 14, weight: .semibold) }
    static var bold:     UIFont { UIFont(name: "NotoSerif-Bold",     size: 14) ?? .systemFont(ofSize: 14, weight: .bold) }
}
