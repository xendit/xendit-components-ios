//
//  XDTComponents.swift
//  XenditComponents
//
//  Created by Ahmad X on 03/05/2026.
//

import Foundation
import UIKit

// MARK: - XDTComponents

/// Objective-C entry point for the Xendit Components iOS SDK.
///
/// Use `XDTComponents` from Objective-C. Swift callers should use `XenditComponents` directly —
/// it has the richer, type-safe API.
///
/// ## Quick start (Objective-C)
/// ```objc
/// // App startup — configure appearance once
/// XDTAppearance *appearance = [XDTAppearance new];
/// appearance.colorPrimary = UIColor.systemBlue;
/// appearance.borderRadius = 12;
/// [XDTComponents initializeWithAppearance:appearance];
///
/// // Present the payment sheet
/// [XDTComponents presentFromViewController:self
///                        componentsSdkKey:@"your-key"
///                                onResult:^(XDTPaymentResult *result) {
///     switch (result.status) {
///         case XDTPaymentStatusSuccess:
///             NSLog(@"Paid — ID: %@  Channel: %@", result.paymentRequestId, result.channelCode);
///             break;
///         case XDTPaymentStatusFailed:
///             NSLog(@"Error [%@]: %@", result.error.xenditCode, result.error.message);
///             break;
///         default:
///             break;
///     }
/// }];
/// ```
@objc(XDTComponents)
public final class XDTComponents: NSObject {

    // MARK: - Singleton

    /// Shared instance for callers that prefer instance-method style.
    /// All functionality is also available via static methods.
    @objc public static let shared = XDTComponents()

    private override init() { super.init() }

    // MARK: - Global configuration

    /// Configures global appearance and registers SDK resources.
    /// Call once on the main thread at app startup, before presenting the payment sheet.
    ///
    /// - Parameter appearance: Visual styling applied to all SDK-rendered UI.
    @objc public static func initializeWithAppearance(_ appearance: XDTAppearance) {
        Task { @MainActor in
            XenditComponents.initialize(appearance: appearance.toSwift())
        }
    }

    // MARK: - Payment sheet

    /// Presents the Xendit payment sheet modally over `viewController`.
    ///
    /// The SDK is retained internally for the lifetime of the sheet and released automatically
    /// on dismissal. Call this from the main thread; `onResult` is always delivered on the
    /// main thread.
    ///
    /// - Parameters:
    ///   - viewController: The view controller from which to present the sheet.
    ///   - componentsSdkKey: Session-scoped key obtained from your backend.
    ///   - onResult: Completion block invoked with the final payment outcome.
    @objc public static func presentFromViewController(
        _ viewController: UIViewController,
        componentsSdkKey: String,
        onResult: @escaping (XDTPaymentResult) -> Void
    ) {
        Task { @MainActor in
            XenditComponents.present(
                from: viewController,
                componentsSdkKey: componentsSdkKey
            ) { result in
                onResult(XDTPaymentResult(swiftResult: result))
            }
        }
    }

    // MARK: - Read-only access

    /// The current SDK version string (e.g. `"v1.0.0"`).
    @objc public static var sdkVersion: String {
        XenditComponents.sdkVersion
    }

    /// A snapshot of the current global appearance configuration.
    @objc public static var currentAppearance: XDTAppearance {
        XDTAppearance(swiftAppearance: XenditComponents.appearance)
    }
}
