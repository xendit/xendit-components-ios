//
//  XenditStringKey.swift
//  XenditComponents
//
//  Created by Ahmad X on 05/05/2026.
//

import Foundation

// MARK: - Localization Keys

enum LocalizationKey: String {

    // MARK: Action

    case actionImageDownloadError = "session::action.image_download_error"
    case actionPaymentConfirmationInstructions = "session::action.payment_confirmation_instructions"
    case actionPaymentMade = "session::action.payment_made"
    case actionSimulatePayment = "session::action.simulate_payment"
    case actionSimulatePaymentInstructions = "session::action.simulate_payment_instructions"

    // MARK: Action — Barcode

    case actionBarcodeAmountToPay = "session::action_barcode.amount_to_pay"
    case actionBarcodeDownloadBarcode = "session::action_barcode.download_barcode"
    case actionBarcodePaymentCode = "session::action_barcode.payment_code"
    case actionBarcodeSeller = "session::action_barcode.seller"

    // MARK: Action — Deeplink

    case actionDeeplinkButton = "session::action_deeplink.button"
    case actionDeeplinkInstructions = "session::action_deeplink.instructions"
    case actionDeeplinkTitle = "session::action_deeplink.title"

    // MARK: Action — Empty List Push Notification

    case actionEmptyListPushNotificationSubtext = "session::action_empty_list_push_notification.subtext"
    case actionEmptyListPushNotificationTitle = "session::action_empty_list_push_notification.title"

    // MARK: Action — OTP

    case actionOtpConfirmButton = "session::action_otp.confirm_button"
    case actionOtpHeaderTitle = "session::action_otp.header_title"
    case actionOtpSubtext = "session::action_otp.subtext"

    // MARK: Action — QR Code

    case actionQrCodeAmountToPay = "session::action_qr_code.amount_to_pay"
    case actionQrCodeDownloadQr = "session::action_qr_code.download_qr"
    case actionQrCodeNmid = "session::action_qr_code.nmid"
    case actionQrCodeScanToPay = "session::action_qr_code.scan_to_pay"
    case actionQrCodeSaved = "session::action_qr_code.saved"
    case actionQrCodeSaveFailed = "session::action_qr_code.save_failed"
    case actionQrCodeUnableToGenerate = "session::action_qr_code.unable_to_generate"

    // MARK: Action — Redirect

    case actionRedirectButton = "session::action_redirect.button"
    case actionRedirectInstructions = "session::action_redirect.instructions"
    case actionRedirectInstructionsCards = "session::action_redirect.instructions_cards"
    case actionRedirectTitle = "session::action_redirect.title"

    // MARK: Action — Virtual Account

    case actionVaAmountToPay = "session::action_va.amount_to_pay"
    case actionVaCopyAmount = "session::action_va.copy_amount"
    case actionVaCopyNumber = "session::action_va.copy_number"
    case actionVaVirtualAccountNumber = "session::action_va.virtual_account_number"
    case actionVaMerchantName = "session::action_va.merchant_name"
    case actionVaTransferTo = "session::action_va.transfer_to"
    case actionVaExpiresAt = "session::action_va.expires_at"
    case actionVaDone = "session::action_va.done"
    case actionVaWaiting = "session::action_va.waiting_for_payment"

    // MARK: Channel Selection

    case channelSelectionAddPaymentMethod = "session::channel_selection.add_payment_method"
    case channelSelectionCompletePayment = "session::channel_selection.complete_payment"
    case channelSelectionConfirmSubscription = "session::channel_selection.confirm_subscription"
    case channelSelectionOrderDetails = "session::channel_selection.order_details"
    case channelSelectionSubscriptionDetails = "session::channel_selection.subscription_details"
    case channelSelectionSubscriptionNoCharge = "session::channel_selection.subscription_no_charge"

    // MARK: Combobox

    case comboboxDefaultNoResults = "session::combobox.default_no_results"
    case comboboxDefaultSearchPlaceholder = "session::combobox.default_search_placeholder"

    // MARK: Clipboard

    case copiedToClipboard = "session::copied_to_clipboard"

    // MARK: Country Picker

    case countryPickerDefaultNoResults = "session::country_picker.default_no_results"
    case countryPickerDefaultPlaceholder = "session::country_picker.default_placeholder"

    // MARK: Crash Error

    case crashErrorSubtext = "session::crash_error.subtext"
    case crashErrorTitle = "session::crash_error.title"

    // MARK: Customer Details

    case customerDetailsButtonLabel = "session::customer_details.button_label"
    case customerDetailsDialogTitle = "session::customer_details.dialog_title"
    case customerDetailsEmail = "session::customer_details.email"
    case customerDetailsFormName = "session::customer_details.form_name"
    case customerDetailsName = "session::customer_details.name"
    case customerDetailsNoAccountInfo = "session::customer_details.no_account_info"
    case customerDetailsPhoneNumber = "session::customer_details.phone_number"

    // MARK: Default Error

    case defaultErrorMessage1 = "session::default_error.message_1"
    case defaultErrorMessage2 = "session::default_error.message_2"
    case defaultErrorTitle = "session::default_error.title"

    // MARK: Dialog

    case dialogClose = "session::dialog.close"

    // MARK: Disclaimer

    case disclaimerFpx = "session::disclaimer.fpx"
    case disclaimerPayAndSaveSubmit = "session::disclaimer.pay_and_save_submit"
    case disclaimerPayCardsManualCaptureSubmit = "session::disclaimer.pay_cards_manual_capture_submit"
    case disclaimerSaveSubmit = "session::disclaimer.save_submit"
    case disclaimerSubscriptionSubmit = "session::disclaimer.subscription_submit"

    // MARK: Expiry Deadline

    case expiryDeadlineMessage = "session::expiry_deadline.message"
    case expiryDeadlineMessageSubscribe = "session::expiry_deadline.message_subscribe"
    case expiryDeadlineTimeToday = "session::expiry_deadline.time_today"
    case expiryDeadlineTimeTomorrow = "session::expiry_deadline.time_tomorrow"

    // MARK: Failure

    case failureBack = "session::failure.back"
    case failureCopyUniqueIdentifiers = "session::failure.copy_unique_identifiers"

    // MARK: Failure Codes

    case failureCodeAccountAccessBlocked = "session::failure_code.account_access_blocked"
    case failureCodeAccountAlreadyLinked = "session::failure_code.account_already_linked"
    case failureCodeAccountNotActivated = "session::failure_code.account_not_activated"
    case failureCodeAuthenticationFailed = "session::failure_code.authentication_failed"
    case failureCodeCaptureAmountExceeded = "session::failure_code.capture_amount_exceeded"
    case failureCodeCardDeclined = "session::failure_code.card_declined"
    case failureCodeChannelUnavailable = "session::failure_code.channel_unavailable"
    case failureCodeDeclinedByIssuer = "session::failure_code.declined_by_issuer"
    case failureCodeDeclinedByProcessor = "session::failure_code.declined_by_processor"
    case failureCodeExpiredCard = "session::failure_code.expired_card"
    case failureCodeExpiredOtp = "session::failure_code.expired_otp"
    case failureCodeFailureDetailsUnavailable = "session::failure_code.failure_details_unavailable"
    case failureCodeInactiveOrUnauthorizedCard = "session::failure_code.inactive_or_unauthorized_card"
    case failureCodeInsufficientBalance = "session::failure_code.insufficient_balance"
    case failureCodeInvalidAccountDetails = "session::failure_code.invalid_account_details"
    case failureCodeInvalidCvv = "session::failure_code.invalid_cvv"
    case failureCodeInvalidMerchantSettings = "session::failure_code.invalid_merchant_settings"
    case failureCodeInvalidOtp = "session::failure_code.invalid_otp"
    case failureCodeInvalidToken = "session::failure_code.invalid_token"
    case failureCodeIssuerUnavailable = "session::failure_code.issuer_unavailable"
    case failureCodeOtpAttemptCountsExceeded = "session::failure_code.otp_attempt_counts_exceeded"
    case failureCodePartnerTimeoutError = "session::failure_code.partner_timeout_error"
    case failureCodePaymentAmountLimitsExceeded = "session::failure_code.payment_amount_limits_exceeded"
    case failureCodePaymentAttemptCountsExceeded = "session::failure_code.payment_attempt_counts_exceeded"
    case failureCodePaymentRequestExpired = "session::failure_code.payment_request_expired"
    case failureCodeProcessorError = "session::failure_code.processor_error"
    case failureCodeServerError = "session::failure_code.server_error"
    case failureCodeStolenCard = "session::failure_code.stolen_card"
    case failureCodeSuspectedFraudulent = "session::failure_code.suspected_fraudulent"
    case failureCodeTimeoutError = "session::failure_code.timeout_error"
    case failureCodeUserDeclinedPayment = "session::failure_code.user_declined_payment"
    case failureCodeUserDeviceUnreachable = "session::failure_code.user_device_unreachable"
    case failureCodeUserDidNotAuthorize = "session::failure_code.user_did_not_authorize"
    case failureCodeUnknown = "session::failure_code_unknown"
    
    // MARK: Apple Pay Errors

    case applePayErrorsMerchantValidationFailedMessage = "session::apple_pay_errors.merchant_validation_failed.message"
    case applePayErrorsMerchantValidationFailedTitle = "session::apple_pay_errors.merchant_validation_failed.title"
    case applePayErrorsNetworkErrorMessage = "session::apple_pay_errors.network_error.message"
    case applePayErrorsNetworkErrorTitle = "session::apple_pay_errors.network_error.title"
    case applePayErrorsUnknownErrorMessage = "session::apple_pay_errors.unknown_error.message"
    case applePayErrorsUnknownErrorTitle = "session::apple_pay_errors.unknown_error.title"

    // MARK: Google Pay Errors

    case googlePayErrorsBuyerAccountErrorMessage = "session::google_pay_errors.buyer_account_error.message"
    case googlePayErrorsBuyerAccountErrorTitle = "session::google_pay_errors.buyer_account_error.title"
    case googlePayErrorsDeveloperErrorMessage = "session::google_pay_errors.developer_error.message"
    case googlePayErrorsDeveloperErrorTitle = "session::google_pay_errors.developer_error.title"
    case googlePayErrorsInternalErrorMessage = "session::google_pay_errors.internal_error.message"
    case googlePayErrorsInternalErrorTitle = "session::google_pay_errors.internal_error.title"
    case googlePayErrorsMerchantAccountErrorMessage = "session::google_pay_errors.merchant_account_error.message"
    case googlePayErrorsMerchantAccountErrorTitle = "session::google_pay_errors.merchant_account_error.title"
    case googlePayErrorsUnknownErrorMessage = "session::google_pay_errors.unknown_error.message"
    case googlePayErrorsUnknownErrorTitle = "session::google_pay_errors.unknown_error.title"

    // MARK: Image Alt

    case imageAltAlert = "session::image_alt.alert"
    case imageAltChannelLogo = "session::image_alt.channel_logo"
    case imageAltClock = "session::image_alt.clock"
    case imageAltCompleted = "session::image_alt.completed"
    case imageAltFacepalm = "session::image_alt.facepalm"
    case imageAltHourglass = "session::image_alt.hourglass"
    case imageAltMail = "session::image_alt.mail"
    case imageAltMerchantLogo = "session::image_alt.merchant_logo"
    case imageAltNametag = "session::image_alt.nametag"
    case imageAltPhone = "session::image_alt.phone"
    case imageAltTick = "session::image_alt.tick"
    case imageAltUser = "session::image_alt.user"

    // MARK: Installment Plan

    case installmentPlanPayInFull = "session::installment_plan.pay_in_full"
    case installmentPlanPayInInstallments = "session::installment_plan.pay_in_installments"

    // MARK: Network Error

    case networkErrorTitle = "session::network_error.title"
    case networkErrorSubtext = "session::network_error.subtext"

    // MARK: Navigation

    case navigationBack = "session::navigation.back"

    // MARK: Page Title

    case pageTitlePay = "session::page_title.pay"
    case pageTitleSave = "session::page_title.save"

    // MARK: Payment

    case paymentSaveCheckboxLabel = "session::payment.save_checkbox_label"
    case paymentEwalletSaveCheckboxLabel = "session::payment.ewallet_save_checkbox_label"

    // MARK: Payment Items

    case paymentItemsDescription = "session::payment_items.description"
    case paymentItemsSubscriptionBillingIntervalDayOne = "session::payment_items.subscription_billing_interval_day_one"
    case paymentItemsSubscriptionBillingIntervalDayOther = "session::payment_items.subscription_billing_interval_day_other"
    case paymentItemsSubscriptionBillingIntervalMonthOne = "session::payment_items.subscription_billing_interval_month_one"
    case paymentItemsSubscriptionBillingIntervalMonthOther = "session::payment_items.subscription_billing_interval_month_other"
    case paymentItemsSubscriptionBillingIntervalWeekOne = "session::payment_items.subscription_billing_interval_week_one"
    case paymentItemsSubscriptionBillingIntervalWeekOther = "session::payment_items.subscription_billing_interval_week_other"
    case paymentItemsSubscriptionBillingSchedule = "session::payment_items.subscription_billing_schedule"
    case paymentItemsSubscriptionFirstCharge = "session::payment_items.subscription_first_charge"
    case paymentItemsSubtotal = "session::payment_items.subtotal"
    case paymentItemsTotal = "session::payment_items.total"
    case paymentItemsUpcomingCharge = "session::payment_items.upcoming_charge"

    // MARK: Payment Methods

    case paymentMethodsAddPaymentMethod = "session::payment_methods.add_payment_method"
    case paymentMethodsChannelDisabledAmountTooLarge = "session::payment_methods.channel_disabled_amount_too_large"
    case paymentMethodsChannelDisabledAmountTooSmall = "session::payment_methods.channel_disabled_amount_too_small"
    case paymentMethodsDigitalWalletOr = "session::payment_methods.digital_wallet_or"
    case paymentMethodsHeader = "session::payment_methods.header_2"
    case paymentMethodsNoAvailablePaymentMethods = "session::payment_methods.no_available_payment_methods"
    case paymentMethodsNoAvailablePaymentMethodsSubtext = "session::payment_methods.no_available_payment_methods_subtext"
    case paymentMethodsPayWith = "session::payment_methods.pay_with"
    case paymentMethodsSelectChannelPlaceholder = "session::payment_methods.select_channel_placeholder"

    // MARK: Payment Methods Submit

    case paymentMethodsSubmitAddPaymentMethod = "session::payment_methods_submit.add_payment_method"
    case paymentMethodsSubmitPay = "session::payment_methods_submit.pay"
    case paymentMethodsSubmitPayToMerchant = "session::payment_methods_submit.pay_to_merchant"
    case paymentMethodsSubmitPayWithChannel = "session::payment_methods_submit.pay_with_channel"
    case paymentMethodsSubmitScheduleDetails = "session::payment_methods_submit.schedule_details"
    case paymentMethodsSubmitSubscribe = "session::payment_methods_submit.subscribe"
    case paymentMethodsSubmitTotalAmount = "session::payment_methods_submit.total_amount"

    // MARK: Payment Request Status

    case paymentRequestStatusCanceledSubtext = "session::payment_request_status.canceled.subtext"
    case paymentRequestStatusCanceledTitle = "session::payment_request_status.canceled.title"
    case paymentRequestStatusExpiredSubtext = "session::payment_request_status.expired.subtext"
    case paymentRequestStatusExpiredTitle = "session::payment_request_status.expired.title"
    case paymentRequestStatusFailedSubtext = "session::payment_request_status.failed.subtext"
    case paymentRequestStatusFailedTitle = "session::payment_request_status.failed.title"

    // MARK: Payment Secured By

    case paymentSecuredBy = "session::payment_secured_by"

    // MARK: Payment Token Status

    case paymentTokenStatusCanceledSubtext = "session::payment_token_status.canceled.subtext"
    case paymentTokenStatusCanceledTitle = "session::payment_token_status.canceled.title"
    case paymentTokenStatusExpiredSubtext = "session::payment_token_status.expired.subtext"
    case paymentTokenStatusExpiredTitle = "session::payment_token_status.expired.title"
    case paymentTokenStatusFailedSubtext = "session::payment_token_status.failed.subtext"
    case paymentTokenStatusFailedTitle = "session::payment_token_status.failed.title"

    // MARK: Session Is Not Payment Link

    case sessionIsNotPaymentLinkSubtext = "session::session_is_not_payment_link.subtext"
    case sessionIsNotPaymentLinkTitle = "session::session_is_not_payment_link.title"

    // MARK: Session Status — Pay

    case sessionStatusPayAlreadyCompletedSubtext = "session::session_status.pay.already_completed.subtext"
    case sessionStatusPayAlreadyCompletedTitle = "session::session_status.pay.already_completed.title"
    case sessionStatusPayCanceledSubtext = "session::session_status.pay.canceled.subtext"
    case sessionStatusPayCanceledTitle = "session::session_status.pay.canceled.title"
    case sessionStatusPayCompletedAmount = "session::session_status.pay.completed.amount"
    case sessionStatusPayCompletedPaidOn = "session::session_status.pay.completed.paid_on"
    case sessionStatusPayCompletedPaidWithChannel = "session::session_status.pay.completed.paid_with_channel"
    case sessionStatusPayCompletedPaymentTo = "session::session_status.pay.completed.payment_to"
    case sessionStatusPayCompletedSubtext = "session::session_status.pay.completed.subtext"
    case sessionStatusPayCompletedTitle = "session::session_status.pay.completed.title"
    case sessionStatusPayExpiredSubtext = "session::session_status.pay.expired.subtext"
    case sessionStatusPayExpiredTitle = "session::session_status.pay.expired.title"
    case sessionStatusPayPendingSubtext = "session::session_status.pay.pending.subtext"
    case sessionStatusPayPendingTitle = "session::session_status.pay.pending.title"

    // MARK: Session Status — Polling

    case sessionStatusPollingSubtext = "session::session_status.polling.subtext"
    case sessionStatusPollingTitle = "session::session_status.polling.title"

    // MARK: Session Status — Save

    case sessionStatusSaveAlreadyCompletedSubtext = "session::session_status.save.already_completed.subtext"
    case sessionStatusSaveAlreadyCompletedTitle = "session::session_status.save.already_completed.title"
    case sessionStatusSaveCanceledSubtext = "session::session_status.save.canceled.subtext"
    case sessionStatusSaveCanceledTitle = "session::session_status.save.canceled.title"
    case sessionStatusSaveCompletedSubtext = "session::session_status.save.completed.subtext"
    case sessionStatusSaveCompletedTitle = "session::session_status.save.completed.title"
    case sessionStatusSaveExpiredSubtext = "session::session_status.save.expired.subtext"
    case sessionStatusSaveExpiredTitle = "session::session_status.save.expired.title"
    case sessionStatusSavePendingSubtext = "session::session_status.save.pending.subtext"
    case sessionStatusSavePendingTitle = "session::session_status.save.pending.title"

    // MARK: Validation

    case validationCardCvnInvalid = "session::validation.card_cvn_invalid"
    case validationCardExpiryInvalid = "session::validation.card_expiry_invalid"
    case validationCardNumberIncomplete = "session::validation.card_number_incomplete"
    case validationCardNumberInvalid = "session::validation.card_number_invalid"
    case validationCardBrandNotSupported = "session::validation.card_brand_not_supported"
    case validationGenericInvalid = "session::validation.generic_invalid"
    case validationRequired = "session::validation.required"
    case validationTextTooLong = "session::validation.text_too_long"
    case validationTextTooShort = "session::validation.text_too_short"

    // MARK: Waiting Payment

    case waitingPaymentMessage1 = "session::waiting_payment.message_1"
    case waitingPaymentMessage2 = "session::waiting_payment.message_2"
    case waitingPaymentMessage2Prefix = "session::waiting_payment.message_2_prefix"
    case waitingPaymentSimulateMessage1 = "session::waiting_payment.simulate.message_1"
    case waitingPaymentTitle = "session::waiting_payment.title"
}
