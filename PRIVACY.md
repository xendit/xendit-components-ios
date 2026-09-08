# Xendit Components iOS — Privacy Details

This document describes all data the SDK handles. Use it to complete your [App Store Privacy Nutrition Label](https://developer.apple.com/app-store/app-privacy-details/).

| Data Type | Is this data used? | How is this data used? | Is this data linked to the end user's identity? | Is this data used for tracking purposes? |
|-----------|-------------------|------------------------|------------------------------------------------|------------------------------------------|
| Payment Info (card number, expiry, CVN) | **Yes.** Collected when the user enters card details in the payment sheet. All data is encrypted on-device before transmission. | App Functionality | **Conditional.** If Xendit associates the payment method with a customer record on your behalf, you may need to disclose this. | **No.** Xendit does not use this data for tracking purposes. |
| Payment Info (Apple Pay token) | **Conditional.** Collected when the user authorizes an Apple Pay payment. The token is provided by Apple's PassKit framework and contains a network-specific cryptogram — card number and CVN are never exposed to the SDK. | App Functionality | **No.** The token is a single-use cryptogram and is not linked to the user's identity by Xendit. | **No.** Xendit does not use this data for tracking purposes. |
| Contact Info (billing name, email, phone, address) | **Conditional.** Collected when your session configuration includes billing address fields (card payments) or requires billing/shipping contact fields (Apple Pay). | App Functionality | **Conditional.** If this data is associated with a payment session or customer record, it may be linked to the end user's identity. | **No.** Xendit does not use this data for tracking purposes. |
| Product Interaction (checkout telemetry) | **Yes.** Behavioral events describing the checkout lifecycle are posted to Xendit's telemetry backend — which payment channels were shown, which was selected, whether the attempt succeeded, and session-level outcomes (loaded, abandoned, ended). No card numbers, CVN, or full contact details are included. | App Functionality | **No.** Events are keyed to the payment session ID, not to the end user's identity. | **No.** Xendit does not use this data for tracking or advertising. |
| App Info (bundle identifier name) | **Yes.** The host app's bundle identifier name is sent with each request for host identification and fraud prevention. | App Functionality, Fraud Prevention | **No.** The bundle identifier name identifies the host application, not the individual end user. | **No.** Xendit does not use this data for tracking purposes. |
| Network Info (IP address) | **Yes.** Transmitted with every HTTP request as an inherent part of network communication. | Fraud Prevention | **No.** Xendit does not link IP addresses to the end user's identity. | **No.** Xendit does not use this data for tracking purposes. |

## Data Handling

**Encryption.** Card number, expiry, and CVN are encrypted on-device using P-384 ECDH + AES-256-GCM before any data leaves the device. Xendit servers receive only the ciphertext; the plaintext never travels over the wire.

**No on-device persistence of payment credentials.** Card numbers, CVN, and Apple Pay tokens are held only in process memory during the payment session and are discarded when the sheet is dismissed.

**No third-party analytics.** The SDK does not embed any advertising or behavioural analytics SDKs. All data is transmitted exclusively to Xendit endpoints.

For full details, see the [Xendit Privacy Policy](https://www.xendit.co/en/privacy-policy/).
