//
//  CreditCardExpiryFieldView.swift
//  XenditComponents
//
//  Created by Ahmad X on 02/05/2026.
//

import SwiftUI

struct CreditCardExpiryFieldView: View {
    let label: String
    let placeholder: String
    @Binding var value: String
    var isDisabled: Bool = false
    var onChanged: (() -> Void)?
    var onEditingEnded: (() -> Void)?

    var body: some View {
        XenditLabeledField(label: label) {
            XenditTextField(
                text: $value,
                placeholder: placeholder.isEmpty ? "MM/YY" : placeholder,
                isDisabled: isDisabled,
                keyboardType: .numberPad,
                uiFont: XenditComponents.appearance.fontFamily?.regular,
                characterFilter: \.isNumber,
                maxLength: 4,
                transform: { text in
                    let digits = String(text.filter(\.isNumber).prefix(4))
                    if digits.count > 2 {
                        let formatted = "\(digits.prefix(2))/\(digits.dropFirst(2))"
                        return (display: formatted, stored: formatted)
                    }
                    return (display: digits, stored: digits)
                },
                onChanged: onChanged,
                onEditingEnded: onEditingEnded
            )
            .padding(.horizontal, Spacing.s3)
            .frame(height: 44)
            .xenditFieldBorder()
        }
    }
}
