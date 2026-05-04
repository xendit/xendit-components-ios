#import "AppDelegate.h"
#import "PlayfairFont.h"
@import XenditComponents;

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [PlayfairFont register];

    // ── Font scenarios ────────────────────────────────────────────────────
    // Pick ONE scenario; comment out the others.
    //
    // Scenario A — All variants: every SDK weight uses Playfair Display.
    XDTFontFamily *fontFamily = [XDTFontFamily new];
    fontFamily.regular  = [PlayfairFont regular];
    fontFamily.medium   = [PlayfairFont medium];
    fontFamily.semiBold = [PlayfairFont semiBold];
    fontFamily.bold     = [PlayfairFont bold];
    //
    // Scenario B — Partial variants: regular + bold only.
    // The SDK falls back to its bundled Inter for medium and semiBold.
    // XDTFontFamily *fontFamily = [XDTFontFamily new];
    // fontFamily.regular = [PlayfairFont regular];
    // fontFamily.bold    = [PlayfairFont bold];
    //
    // Scenario C — No custom font: the SDK uses its default Inter throughout.
    // XDTFontFamily *fontFamily = nil;
    // ─────────────────────────────────────────────────────────────────────

    // ── Appearance scenarios ──────────────────────────────────────────────
    // Pick ONE scenario; comment out the others.
    // fontFamily from the font scenario above is always forwarded.
    //
    // Scenario 1 — Full customization: every appearance parameter set.
    XDTAppearance *appearance = [XDTAppearance new];
    appearance.fontFamily          = fontFamily;
    appearance.colorPrimary        = UIColor.systemIndigoColor;
    appearance.colorText           = UIColor.labelColor;
    appearance.colorTextSecondary  = UIColor.secondaryLabelColor;
    appearance.colorTextPlaceholder = UIColor.placeholderTextColor;
    appearance.colorDisabled       = UIColor.systemGray5Color;
    appearance.colorDanger         = UIColor.systemRedColor;
    appearance.colorBorder         = UIColor.systemGray3Color;
    appearance.colorBackground     = UIColor.systemBackgroundColor;
    appearance.qrForegroundColor   = UIColor.blackColor;  // note: has no effect on QR dot pixels (API-rendered bitmap)
    appearance.qrBackgroundColor   = UIColor.whiteColor;
    appearance.borderRadius        = 12;
    //
    // Scenario 2 — Partial customization: brand color, danger, and corner radius only.
    // All other properties fall back to the SDK's design-system defaults.
    // XDTAppearance *appearance = [XDTAppearance new];
    // appearance.fontFamily   = fontFamily;
    // appearance.colorPrimary = UIColor.systemTealColor;
    // appearance.colorDanger  = UIColor.systemOrangeColor;
    // appearance.borderRadius = 6;
    //
    // Scenario 3 — SDK defaults: only the font family is forwarded; everything
    // else uses the built-in design-system values.
    // XDTAppearance *appearance = [XDTAppearance new];
    // appearance.fontFamily = fontFamily;
    // ─────────────────────────────────────────────────────────────────────

    [XDTComponents initializeWithAppearance:appearance];
    return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application
configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession
                               options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration"
                                          sessionRole:connectingSceneSession.role];
}

@end
