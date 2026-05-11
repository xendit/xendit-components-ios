//
//  CreditCardCvnFieldView.swift
//  XenditComponents
//
//  Created by Ahmad X on 02/05/2026.
//

import SwiftUI

struct CreditCardCvnFieldView: View {
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
                placeholder: placeholder.isEmpty ? "CVN" : placeholder,
                isSecure: true,
                isDisabled: isDisabled,
                keyboardType: .numberPad,
                uiFont: XenditComponents.appearance.fontFamily?.regular,
                characterFilter: \.isNumber,
                maxLength: 4,
                onChanged: onChanged,
                onEditingEnded: onEditingEnded
            )
            .padding(.horizontal, Spacing.s3)
            .frame(height: 44)
            .xenditFieldBorder()
        }
    }
}
