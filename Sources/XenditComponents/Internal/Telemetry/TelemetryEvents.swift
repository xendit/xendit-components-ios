//
//  TelemetryEvents.swift
//  XenditComponents
//

import Foundation

/// Factory methods for every telemetry event. Mirror of the web SDK's TelemetryEvents object.
/// CHECKOUT_RESUME and CHECKOUT_REDIRECT_AWAY are web-only and not included here.
enum TelemetryEvents {

    /// On initialization, after the get-session call succeeds or fails.
    static func loaded(success: Bool, channels: [String]? = nil) -> SessionTelemetryEvent {
        SessionTelemetryEvent(stage: "CHECKOUT_LOADED", success: success,
                              metadata: channels.map { (arr: [String]) -> [String: Any] in ["channels": arr] })
    }

    /// On channel group header tap (multi-channel groups only).
    static func channelGroup(success: Bool, groupName: String, channels: [String]? = nil) -> SessionTelemetryEvent {
        var meta: [String: Any] = ["group_name": groupName]
        if let channels { meta["channels"] = channels }
        return SessionTelemetryEvent(stage: "CHECKOUT_CHANNEL_GROUP", success: success, metadata: meta)
    }

    /// When a digital wallet button becomes visible to the user (e.g. "APPLE_PAY").
    static func digitalWalletLoaded(success: Bool, digitalWallet: String) -> SessionTelemetryEvent {
        SessionTelemetryEvent(stage: "CHECKOUT_DIGITAL_WALLET_LOADED", success: success,
                              metadata: ["digital_wallet": digitalWallet])
    }

    /// On current channel change.
    static func channel(success: Bool, paymentChannel: String) -> SessionTelemetryEvent {
        SessionTelemetryEvent(stage: "CHECKOUT_CHANNEL", success: success,
                              paymentChannel: paymentChannel)
    }

    /// First time each form field is modified.
    static func channelFormInput(success: Bool, fieldName: String) -> SessionTelemetryEvent {
        SessionTelemetryEvent(stage: "CHECKOUT_CHANNEL_FORM_INPUT", success: success,
                              metadata: ["field_name": fieldName])
    }

    /// On PR/PT request sent.
    static func attemptBegin(success: Bool, validationError: String? = nil) -> SessionTelemetryEvent {
        SessionTelemetryEvent(stage: "CHECKOUT_ATTEMPT_BEGIN", success: success,
                              metadata: validationError.map { ["validation_error": $0] })
    }

    /// On payment request response received.
    static func attemptPR(success: Bool, paymentRequestId: String) -> SessionTelemetryEvent {
        SessionTelemetryEvent(stage: "CHECKOUT_ATTEMPT", success: success,
                              paymentRequestId: paymentRequestId)
    }

    /// On payment token response received.
    static func attemptPT(success: Bool, paymentTokenId: String) -> SessionTelemetryEvent {
        SessionTelemetryEvent(stage: "CHECKOUT_ATTEMPT", success: success,
                              paymentTokenId: paymentTokenId)
    }

    /// On PR/PT request failure.
    static func attemptError(success: Bool, errorCode: String? = nil) -> SessionTelemetryEvent {
        SessionTelemetryEvent(stage: "CHECKOUT_ATTEMPT", success: success,
                              metadata: errorCode.map { ["error_code": $0] })
    }

    /// When an attempt fails (payment failure screen) or the user aborts.
    static func attemptDiscard(success: Bool, failureCode: String? = nil) -> SessionTelemetryEvent {
        SessionTelemetryEvent(stage: "CHECKOUT_ATTEMPT_DISCARD", success: success,
                              metadata: failureCode.map { ["failure_code": $0] })
    }

    /// On action screen shown (VA/QR/OTC/webview).
    static func actionBegin(success: Bool) -> SessionTelemetryEvent {
        SessionTelemetryEvent(stage: "CHECKOUT_ACTION_BEGIN", success: success)
    }

    /// When an action screen closes.
    static func actionClose(success: Bool) -> SessionTelemetryEvent {
        SessionTelemetryEvent(stage: "CHECKOUT_ACTION_CLOSE", success: success)
    }

    /// When a digital wallet button is tapped (e.g. "APPLE_PAY").
    static func digitalWalletBegin(success: Bool, digitalWallet: String) -> SessionTelemetryEvent {
        SessionTelemetryEvent(stage: "CHECKOUT_DIGITAL_WALLET_BEGIN", success: success,
                              metadata: ["digital_wallet": digitalWallet])
    }

    /// When a digital wallet flow completes or is closed.
    static func digitalWalletClose(success: Bool, errorCode: String? = nil) -> SessionTelemetryEvent {
        SessionTelemetryEvent(stage: "CHECKOUT_DIGITAL_WALLET_CLOSE", success: success,
                              metadata: errorCode.map { ["error_code": $0] })
    }

    /// When a VA/OTC copy button is pressed.
    static func actionCopyText(success: Bool, fieldName: String) -> SessionTelemetryEvent {
        SessionTelemetryEvent(stage: "CHECKOUT_ACTION_COPY_TEXT", success: success,
                              metadata: ["field_name": fieldName])
    }

    /// On session complete, expiry, or cancellation.
    static func end(success: Bool, status: String) -> SessionTelemetryEvent {
        SessionTelemetryEvent(stage: "CHECKOUT_END", success: success,
                              metadata: ["status": status])
    }

    /// On session-level pending state (not PR/PT pending).
    static func pending(success: Bool) -> SessionTelemetryEvent {
        SessionTelemetryEvent(stage: "CHECKOUT_PENDING", success: success)
    }

    /// User dismissed the sheet before the session reached a terminal state.
    static func abandon(success: Bool) -> SessionTelemetryEvent {
        SessionTelemetryEvent(stage: "CHECKOUT_ABANDON", success: success)
    }
}
