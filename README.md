# Xendit Components iOS

A drop-in payment UI SDK for iOS that lets you accept payments through Xendit with minimal integration effort. Present a fully featured payment sheet in just a few lines of code.

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)](https://github.com/xendit/xendit-components-ios)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](https://github.com/xendit/xendit-components-ios/releases)
[![License](https://img.shields.io/badge/license-MIT-lightgrey)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-iOS%2015%2B-orange)](https://developer.apple.com/ios/)

## Features

- **Pre-built payment sheet** — Full-screen payment UI with channel selection, form validation, and error handling out of the box.
- **Apple Pay** — Native Apple Pay sheet, automatically shown when the session has Apple Pay enabled. No additional code required in the host app beyond the entitlement.
- **3DS & redirect handling** — Built-in WebView for 3D Secure challenges and redirect-based payment flows.
- **Customizable appearance** — Configure colors, fonts, and corner radius to match your brand.
- **SwiftUI & UIKit** — Works with both UI frameworks.
- **Secure by default** — Client-side encryption of sensitive card data using ECDH + AES-GCM.

## Requirements

| Requirement | Minimum |
|-------------|---------|
| iOS         | 15.0    |
| Xcode       | 14.0    |
| Swift       | 5.7     |

## Getting Started

### Quick Start (UIKit)

```swift
import XenditComponents

// 1. Initialize once at app startup
XenditComponents.initialize(appearance: XenditAppearance())

// 2. Present the payment sheet
XenditComponents.present(
    from: viewController,
    componentsSdkKey: "<your_components_sdk_key>"
) { result in
    switch result {
    case .success(let paymentRequestId, let channelCode):
        print("Payment succeeded: \(paymentRequestId)")
    case .failed(let error):
        print("Payment failed: \(error.message)")
    case .canceled:
        print("Session canceled")
    case .expired:
        print("Session expired")
    case .dismissed:
        print("User dismissed")
    }
}
```

### Quick Start (SwiftUI)

```swift
import SwiftUI
import XenditComponents

struct CheckoutView: View {
    var body: some View {
        Button("Pay with Xendit") {
            guard let rootVC = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first?.rootViewController else { return }

            XenditComponents.initialize(appearance: XenditAppearance())
            XenditComponents.present(
                from: rootVC,
                componentsSdkKey: "<your_components_sdk_key>"
            ) { result in
                switch result {
                case .success(let id, _): print("Paid: \(id)")
                case .failed(let error):  print("Error: \(error.message)")
                case .canceled, .expired, .dismissed: break
                }
            }
        }
    }
}
```

### Quick Start (Objective-C)

```objc
@import XenditComponents;

// 1. Initialize once at app startup
XDTAppearance *appearance = [XDTAppearance new];
appearance.colorPrimary = UIColor.systemBlueColor;
appearance.borderRadius = 12;
[XDTComponents initializeWithAppearance:appearance];

// 2. Present the payment sheet
[XDTComponents presentFromViewController:self
                       componentsSdkKey:@"<your_components_sdk_key>"
                               onResult:^(XDTPaymentResult *result) {
    switch (result.status) {
        case XDTPaymentStatusSuccess:
            NSLog(@"Paid — ID: %@", result.paymentRequestId);
            break;
        case XDTPaymentStatusFailed:
            NSLog(@"Error: %@", result.error.message);
            break;
        default:
            break;
    }
}];
```

The `components_sdk_key` is obtained from the [Create Session](https://developers.xendit.co) API response on your backend.

## Payment Method Preference

Merchants can control which payment methods are shown in the payment sheet, and in what order, by passing `merchantPreferredPaymentMethod` to `present(from:componentsSdkKey:merchantPreferredPaymentMethod:onResult:)`.

When provided, only the listed types are shown and they appear in the specified order. Pass `nil` (the default) to show all available payment methods in the server's default order.

The following values are supported:

- `.cards`
- `.ewallet`
- `.qrCode`
- `.virtualAccount`
- `.bankTransfer`
- `.directDebit`
- `.overTheCounter`

### Swift

```swift
XenditComponents.present(
    from: viewController,
    componentsSdkKey: "<your_components_sdk_key>",
    merchantPreferredPaymentMethod: [.ewallet, .cards]
) { result in
    switch result {
    case .success(let id, _): print("Paid: \(id)")
    case .failed(let error):  print("Error: \(error.message)")
    case .canceled, .expired, .dismissed: break
    }
}
```

### Objective-C

```objc
[XDTComponents presentFromViewController:self
                       componentsSdkKey:@"<your_components_sdk_key>"
          merchantPreferredPaymentMethod:@[@(XDTPaymentMethodEwallet), @(XDTPaymentMethodCards)]
                               onResult:^(XDTPaymentResult *result) {
    switch (result.status) {
        case XDTPaymentStatusSuccess:
            NSLog(@"Paid: %@", result.paymentRequestId);
            break;
        case XDTPaymentStatusFailed:
            NSLog(@"Error: %@", result.error.message);
            break;
        default:
            break;
    }
}];
```

## Apple Pay

Apple Pay is enabled server-side via the session configuration. When the session response includes Apple Pay data, the SDK automatically presents a native Apple Pay button. No changes are required in the host app's `present(...)` call.

### Requirements

1. **Apple Pay entitlement** — Add the Apple Pay capability to your app target in Xcode (Signing & Capabilities → + Capability → Apple Pay) and include your merchant ID.

2. **Merchant identifier** — The merchant ID is provided by Xendit and is embedded in the session response. You do not pass it to the SDK directly.

The Apple Pay button is only shown on devices where the user has a card configured for the presented networks. On simulators or devices without an eligible wallet, the button does not appear.

## Appearance Customization

Use `XenditAppearance` to match the payment sheet to your brand. All properties are optional — any you omit fall back to the SDK's built-in defaults.

### Property Reference

| Property | Type | Description |
|----------|------|-------------|
| `fontFamily` | `XenditFontFamily?` | Custom fonts per weight (regular, medium, semiBold, bold). Unset weights fall back to the bundled Inter font. |
| `colorPrimary` | `UIColor?` | Primary CTA color — pay button, selected states, checkmarks. |
| `colorText` | `UIColor?` | Main body text color. |
| `colorTextSecondary` | `UIColor?` | Subtitle and caption text color. |
| `colorTextPlaceholder` | `UIColor?` | Placeholder text inside input fields. |
| `colorDisabled` | `UIColor?` | Background of disabled buttons and controls. |
| `colorDanger` | `UIColor?` | Error messages and invalid field borders. |
| `colorBorder` | `UIColor?` | Input field outlines and dividers. |
| `colorBackground` | `UIColor?` | Sheet and page background. |
| `qrForegroundColor` | `UIColor?` | Tint of the container shown around the QR code image. |
| `qrBackgroundColor` | `UIColor?` | Background of the container box behind the QR code image. |
| `borderRadius` | `CGFloat?` | Corner radius (pt) for buttons, fields, and cards. |
| `customLoadingView` | `AnyView?` | SwiftUI view shown during loading. Defaults to a standard `ProgressView`. Swift only — not available in Objective-C. |

### SwiftUI

```swift
import SwiftUI
import XenditComponents

struct CheckoutView: View {
    var body: some View {
        Button("Pay with Xendit") {
            let appearance = XenditAppearance(
                fontFamily: XenditFontFamily(
                    regular:  UIFont(name: "Inter-Regular",  size: 16),
                    medium:   UIFont(name: "Inter-Medium",   size: 16),
                    semiBold: UIFont(name: "Inter-SemiBold", size: 16),
                    bold:     UIFont(name: "Inter-Bold",     size: 16)
                ),
                colorPrimary:         UIColor(Color.accentColor),
                colorText:            UIColor(Color.primary),
                colorTextSecondary:   UIColor(Color.secondary),
                colorTextPlaceholder: UIColor(Color.secondary.opacity(0.6)),
                colorDanger:          UIColor(Color.red),
                colorBorder:          UIColor(Color.gray.opacity(0.3)),
                colorBackground:      UIColor(Color(.systemBackground)),
                borderRadius:         12,
                customLoadingView:    AnyView(
                    ProgressView().tint(Color.accentColor)
                )
            )

            guard let rootVC = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first?.rootViewController else { return }

            XenditComponents.initialize(appearance: appearance)
            XenditComponents.present(
                from: rootVC,
                componentsSdkKey: "<your_components_sdk_key>"
            ) { result in
                switch result {
                case .success(let id, _): print("Paid: \(id)")
                case .failed(let error):  print("Error: \(error.message)")
                case .canceled, .expired, .dismissed: break
                }
            }
        }
    }
}
```

### UIKit (Swift)

```swift
import UIKit
import XenditComponents

class CheckoutViewController: UIViewController {

    func presentPayment() {
        let appearance = XenditAppearance(
            fontFamily: XenditFontFamily(
                regular:  UIFont(name: "Inter-Regular",  size: 16),
                medium:   UIFont(name: "Inter-Medium",   size: 16),
                semiBold: UIFont(name: "Inter-SemiBold", size: 16),
                bold:     UIFont(name: "Inter-Bold",     size: 16)
            ),
            colorPrimary:         UIColor.systemBlue,
            colorText:            UIColor.label,
            colorTextSecondary:   UIColor.secondaryLabel,
            colorTextPlaceholder: UIColor.placeholderText,
            colorDisabled:        UIColor.systemGray4,
            colorDanger:          UIColor.systemRed,
            colorBorder:          UIColor.separator,
            colorBackground:      UIColor.systemBackground,
            qrForegroundColor:    UIColor.black,
            qrBackgroundColor:    UIColor.white,
            borderRadius:         12
        )

        XenditComponents.initialize(appearance: appearance)
        XenditComponents.present(
            from: self,
            componentsSdkKey: "<your_components_sdk_key>"
        ) { result in
            switch result {
            case .success(let paymentRequestId, let channelCode):
                print("Payment succeeded: \(paymentRequestId)")
            case .failed(let error):
                print("Payment failed: \(error.message)")
            case .canceled:
                print("Session canceled")
            case .expired:
                print("Session expired")
            case .dismissed:
                print("User dismissed")
            }
        }
    }
}
```

### Objective-C

```objc
@import XenditComponents;

- (void)presentPayment {
    XDTFontFamily *fonts = [XDTFontFamily new];
    fonts.regular  = [UIFont fontWithName:@"Inter-Regular"  size:16];
    fonts.medium   = [UIFont fontWithName:@"Inter-Medium"   size:16];
    fonts.semiBold = [UIFont fontWithName:@"Inter-SemiBold" size:16];
    fonts.bold     = [UIFont fontWithName:@"Inter-Bold"     size:16];

    XDTAppearance *appearance = [XDTAppearance new];
    appearance.fontFamily            = fonts;
    appearance.colorPrimary          = UIColor.systemBlueColor;
    appearance.colorText             = UIColor.labelColor;
    appearance.colorTextSecondary    = UIColor.secondaryLabelColor;
    appearance.colorTextPlaceholder  = UIColor.placeholderTextColor;
    appearance.colorDisabled         = UIColor.systemGray4Color;
    appearance.colorDanger           = UIColor.systemRedColor;
    appearance.colorBorder           = UIColor.separatorColor;
    appearance.colorBackground       = UIColor.systemBackgroundColor;
    appearance.qrForegroundColor     = UIColor.blackColor;
    appearance.qrBackgroundColor     = UIColor.whiteColor;
    appearance.borderRadius          = 12;

    [XDTComponents initializeWithAppearance:appearance];
    [XDTComponents presentFromViewController:self
                           componentsSdkKey:@"<your_components_sdk_key>"
                                   onResult:^(XDTPaymentResult *result) {
        switch (result.status) {
            case XDTPaymentStatusSuccess:
                NSLog(@"Payment succeeded: %@", result.paymentRequestId);
                break;
            case XDTPaymentStatusFailed:
                NSLog(@"Payment failed: %@", result.error.message);
                break;
            case XDTPaymentStatusCanceled:
                NSLog(@"Session canceled");
                break;
            case XDTPaymentStatusExpired:
                NSLog(@"Session expired");
                break;
            case XDTPaymentStatusDismissed:
                NSLog(@"User dismissed");
                break;
        }
    }];
}
```

> **Note (Objective-C):** `customLoadingView` requires SwiftUI and is not available from Objective-C. To supply a custom loading indicator, use `XenditAppearance` from a Swift file in your project.

### Calling `initialize` more than once

`XenditComponents.initialize(appearance:)` can be called multiple times. Each call replaces the active appearance for all subsequent `present(...)` calls. This lets you apply different themes at runtime without restarting the session.

## Installation

### Swift Package Manager

#### Xcode

1. In Xcode, go to **File → Add Package Dependencies…**
2. Enter the repository URL:
   ```
   https://github.com/xendit/xendit-components-ios.git
   ```
3. Select **Up to Next Major Version** with `1.1.0`.
4. Add `XenditComponents` to your app target.

#### Package.swift

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/xendit/xendit-components-ios.git", from: "1.1.0")
]
```

Then add `XenditComponents` to your target's dependencies:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "XenditComponents", package: "xendit-components-ios")
    ]
)
```

## Documentation & Examples

| Resource | Description |
|----------|-------------|
| [API Reference](https://developers.xendit.co) | Full API documentation for session creation and payment flows. |
| [SwiftUI Example](Example/XenditExample) | Sample SwiftUI app demonstrating SDK integration. |
| [UIKit Example](Example/XenditExampleUIKit) | Sample UIKit app demonstrating SDK integration. |
| [Obj-C Example](Example/XenditExampleObjC) | Sample Objective-C app using the SDK bridge. |

## Security

The SDK sends card data to Xendit over TLS, protected by [App Transport Security (ATS)](https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity), which is enabled by default and enforces TLS 1.2+ with forward secrecy.

> **Do not weaken App Transport Security for Xendit traffic.** In your app's `Info.plist`, do not set `NSAllowsArbitraryLoads` (or `NSAllowsArbitraryLoadsInWebContent`) to `true`, and do not add an `NSExceptionDomains` entry for Xendit hosts that sets `NSExceptionAllowsInsecureHTTPLoads` or lowers `NSExceptionMinimumTLSVersion`. Any of these re-enables downgrade and interception of the payment session.

## Privacy

See [PRIVACY.md](PRIVACY.md) for a full breakdown of data collected, how it is used, whether it is linked to the end user's identity, and whether it is used for tracking — formatted for [App Store Privacy Nutrition Labels](https://developer.apple.com/app-store/app-privacy-details/).

## License

Xendit Components iOS is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
