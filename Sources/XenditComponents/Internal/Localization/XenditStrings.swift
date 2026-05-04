//
//  XenditStrings.swift
//  XenditComponents
//
//  Created by Ahmad X on 04/05/2026.
//

import Foundation

// MARK: - Localization

struct XenditStrings {
    private let locale: String

    init(locale: String) {
        self.locale = XenditStrings.normalizeLocale(locale)
    }

    func string(forKey key: String, replacements: [String: String] = [:]) -> String {
        let table = Self.strings[locale] ?? Self.strings["en"] ?? [:]
        var value = table[key] ?? Self.strings["en"]?[key] ?? key

        for (placeholder, replacement) in replacements {
            value = value.replacingOccurrences(of: "{{\(placeholder)}}", with: replacement)
        }
        return value
    }

    func validationMessage(forCode code: String, fieldLabel: String) -> String {
        let key = "validation.\(code)"
        return string(forKey: key, replacements: ["field": fieldLabel])
    }

    func failureMessage(forCode code: String) -> String {
        let key = "failure_code.\(code.lowercased())"
        return string(forKey: key)
    }

    private static func normalizeLocale(_ locale: String) -> String {
        let base = locale.split(separator: "-").first.map(String.init) ?? locale
        let supported = ["en", "id", "th", "vi"]
        return supported.contains(base) ? base : "en"
    }

    static let strings: [String: [String: String]] = [
        "en": [
            "validation.card_cvn_invalid": "CVN is not valid",
            "validation.card_expiry_invalid": "Card expiry is not valid",
            "validation.card_number_incomplete": "Card number is incomplete",
            "validation.card_number_invalid": "Card number is not valid",
            "validation.generic_invalid": "{{field}} is not valid",
            "validation.required": "{{field}} is required",
            "validation.text_too_long": "{{field}} is too long",
            "validation.text_too_short": "{{field}} is too short",
            "payment.pay_button_label": "Pay",
            "payment.save_button_label": "Save",
            "payment.save_checkbox_label": "Save for faster payment next time",
            "payment_methods.sheet_title": "Select Payment Method",
            "payment_methods.add_payment_method": "Add payment method",
            "payment_methods.channel_disabled_amount_too_large": "Not available for this payment",
            "payment_methods.channel_disabled_amount_too_small": "Not available for this payment",
            "payment_methods.pay_with": "Pay with",
            "payment_methods.select_channel_placeholder": "Select {{groupName}}",
            "default_error.message_1": "There was a problem with the request.",
            "default_error.message_2": "Please try again later.",
            "default_error.title": "Error",
            "failure_code.account_access_blocked": "Your payment was declined. Please try again or use a different payment method.",
            "failure_code.account_already_linked": "Your account has already been linked. Please use a different payment method.",
            "failure_code.account_not_activated": "Your payment couldn't be processed because your account hasn't been activated. Please activate your account and try again.",
            "failure_code.authentication_failed": "Your payment couldn't be processed. Please try again or use a different payment method.",
            "failure_code.card_declined": "Your card was declined. Please try again with another card or payment method.",
            "failure_code.channel_unavailable": "Your payment couldn't be processed. Please try again or use a different payment method.",
            "failure_code.insufficient_balance": "Your payment couldn't be processed because your account balance is insufficient. Please make sure you have enough funds and try again.",
            "failure_code.invalid_account_details": "Your payment information is incorrect. Please double-check your card details or try a different payment method.",
            "failure_code.invalid_cvv": "The CVN entered was incorrect. Please try again.",
            "failure_code.issuer_unavailable": "Your payment couldn't be processed. Please try again or use a different payment method.",
            "failure_code.server_error": "Your payment couldn't be processed. Please try again or use a different payment method.",
            "failure_code.timeout_error": "Your payment couldn't be processed. Please try again or use a different payment method.",
            "failure_code.user_declined_payment": "Your payment was declined. Please try again or use a different payment method.",
            "payment_request_status.canceled.subtext": "Please try to check out again or contact the seller if the problem persists.",
            "payment_request_status.canceled.title": "This page is no longer available",
            "payment_request_status.expired.subtext": "Your payment couldn't be processed. Please try again or use a different payment method.",
            "payment_request_status.expired.title": "Payment unsuccessful",
            "payment_request_status.failed.subtext": "Your payment couldn't be processed. Please try a different payment method.",
            "payment_request_status.failed.title": "Payment failed",
            "payment_token_status.canceled.subtext": "Please try again or use a different payment method.",
            "payment_token_status.canceled.title": "Payment method couldn't be added",
            "payment_token_status.expired.subtext": "Please try again or use a different payment method.",
            "payment_token_status.expired.title": "Payment method couldn't be added",
            "payment_token_status.failed.subtext": "Your payment couldn't be processed. Please try a different payment method.",
            "payment_token_status.failed.title": "Payment method couldn't be added"
        ],
        "id": [
            "validation.generic_invalid": "{{field}} tidak valid",
            "validation.required": "{{field}} diperlukan",
            "validation.text_too_long": "{{field}} terlalu panjang",
            "validation.text_too_short": "{{field}} terlalu pendek",
            "payment.pay_button_label": "Bayar",
            "payment.save_button_label": "Simpan",
            "payment.save_checkbox_label": "Simpan untuk pembayaran lebih cepat lain kali",
            "payment_methods.sheet_title": "Pilih Metode Pembayaran",
            "payment_methods.add_payment_method": "Tambah metode pembayaran",
            "payment_methods.pay_with": "Bayar dengan",
            "default_error.message_1": "Ada masalah dengan permintaan.",
            "default_error.message_2": "Silakan coba lagi nanti.",
            "default_error.title": "Error",
            "failure_code.card_declined": "Kartu Anda ditolak. Silakan coba lagi dengan kartu atau metode pembayaran lain.",
            "failure_code.insufficient_balance": "Saldo Anda tidak mencukupi. Pastikan saldo Anda cukup dan coba lagi.",
            "payment_request_status.failed.title": "Pembayaran gagal",
            "payment_request_status.failed.subtext": "Pembayaran Anda tidak dapat diproses. Silakan coba metode pembayaran lain.",
            "payment_token_status.failed.title": "Metode pembayaran tidak dapat ditambahkan",
            "payment_token_status.failed.subtext": "Pembayaran Anda tidak dapat diproses. Silakan coba metode pembayaran lain."
        ],
        "th": [
            "validation.generic_invalid": "{{field}} ไม่ถูกต้อง",
            "validation.required": "{{field}} จำเป็นต้องกรอก",
            "validation.text_too_long": "{{field}} ยาวเกินไป",
            "validation.text_too_short": "{{field}} สั้นเกินไป",
            "payment.pay_button_label": "ชำระเงิน",
            "payment.save_button_label": "บันทึก",
            "payment.save_checkbox_label": "บันทึกไว้สำหรับการชำระเงินที่เร็วขึ้นในครั้งถัดไป",
            "payment_methods.sheet_title": "เลือกวิธีการชำระเงิน",
            "payment_methods.add_payment_method": "เพิ่มวิธีการชำระเงิน",
            "payment_methods.pay_with": "ชำระด้วย",
            "default_error.message_1": "มีปัญหากับคำขอ",
            "default_error.message_2": "โปรดลองอีกครั้งในภายหลัง",
            "default_error.title": "ข้อผิดพลาด",
            "payment_request_status.failed.title": "การชำระเงินล้มเหลว",
            "payment_request_status.failed.subtext": "ไม่สามารถประมวลผลการชำระเงินของคุณ โปรดลองวิธีการชำระเงินอื่น"
        ],
        "vi": [
            "validation.generic_invalid": "{{field}} không hợp lệ",
            "validation.required": "{{field}} là bắt buộc",
            "validation.text_too_long": "{{field}} quá dài",
            "validation.text_too_short": "{{field}} quá ngắn",
            "payment.pay_button_label": "Thanh toán",
            "payment.save_button_label": "Lưu",
            "payment.save_checkbox_label": "Lưu để thanh toán nhanh hơn lần sau",
            "payment_methods.sheet_title": "Chọn Phương Thức Thanh Toán",
            "payment_methods.add_payment_method": "Thêm phương thức thanh toán",
            "payment_methods.pay_with": "Thanh toán bằng",
            "default_error.message_1": "Có lỗi xảy ra với yêu cầu.",
            "default_error.message_2": "Vui lòng thử lại sau.",
            "default_error.title": "Lỗi",
            "payment_request_status.failed.title": "Thanh toán thất bại",
            "payment_request_status.failed.subtext": "Không thể xử lý thanh toán của bạn. Vui lòng thử phương thức thanh toán khác."
        ]
    ]
}
