import UIKit
import XenditComponents

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        PlayfairFont.register()

        // ── Font scenarios ────────────────────────────────────────────────────
        // Pick ONE scenario; comment out the others.
        //
        // Scenario A — All variants: every SDK weight uses Playfair Display.
        let fontFamily = XenditFontFamily(
            regular:  PlayfairFont.regular,
            medium:   PlayfairFont.medium,
            semiBold: PlayfairFont.semiBold,
            bold:     PlayfairFont.bold
        )
        //
        // Scenario B — Partial variants: regular + bold only.
        // The SDK falls back to its bundled Inter for medium and semiBold.
        // let fontFamily = XenditFontFamily(
        //     regular: PlayfairFont.regular,
        //     bold:    PlayfairFont.bold
        // )
        //
        // Scenario C — No custom font: the SDK uses its default Inter throughout.
        // let fontFamily: XenditFontFamily? = nil
        // ─────────────────────────────────────────────────────────────────────

        // ── Appearance scenarios ──────────────────────────────────────────────
        // Pick ONE scenario; comment out the others.
        // `fontFamily` from the font scenario above is always forwarded.
        //
        // Scenario 1 — Full customization: every appearance parameter set.
        let appearance = XenditAppearance(
            fontFamily:          fontFamily,
            colorPrimary:        UIColor.systemIndigo,
            colorText:           UIColor.label,
            colorTextSecondary:  UIColor.secondaryLabel,
            colorTextPlaceholder: UIColor.placeholderText,
            colorDisabled:       UIColor.systemGray5,
            colorDanger:         UIColor.systemRed,
            colorBorder:         UIColor.systemGray3,
            colorBackground:     UIColor.systemBackground,
            qrForegroundColor:   UIColor.black,   // note: has no effect on QR dot pixels (API-rendered bitmap)
            qrBackgroundColor:   UIColor.white,
            borderRadius:        12
            // customLoadingView: AnyView(UIActivityIndicatorView()) — wrap a UIView in UIViewRepresentable
        )
        //
        // Scenario 2 — Partial customization: brand color, danger, and corner radius only.
        // All other properties fall back to the SDK's design-system defaults.
        // let appearance = XenditAppearance(
        //     fontFamily:   fontFamily,
        //     colorPrimary: UIColor.systemTeal,
        //     colorDanger:  UIColor.systemOrange,
        //     borderRadius: 6
        // )
        //
        // Scenario 3 — SDK defaults: only the font family is forwarded; everything
        // else uses the built-in design-system values.
        // let appearance = XenditAppearance(fontFamily: fontFamily)
        // ─────────────────────────────────────────────────────────────────────

        XenditComponents.initialize(appearance: appearance)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
