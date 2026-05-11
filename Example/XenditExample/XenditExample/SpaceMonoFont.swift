import CoreText
import UIKit

enum SpaceMonoFont {

    static func register() {
        let names = [
            "SpaceMono-Regular",
            "SpaceMono-Bold",
        ]
        for name in names {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                print("[XenditExample] '\(name).ttf' not found in bundle — add it to Copy Bundle Resources in Xcode.")
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    static var regular: UIFont { UIFont(name: "SpaceMono-Regular", size: 14) ?? .monospacedSystemFont(ofSize: 14, weight: .regular) }
    static var bold:    UIFont { UIFont(name: "SpaceMono-Bold",    size: 14) ?? .monospacedSystemFont(ofSize: 14, weight: .bold) }
}
