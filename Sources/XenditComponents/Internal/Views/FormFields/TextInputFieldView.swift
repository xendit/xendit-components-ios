//
//  TextInputFieldView.swift
//  XenditComponents
//
//  Created by Ahmad X on 01/05/2026.
//

import SwiftUI
import UIKit

struct TextInputFieldView: View {
    let label: String
    let placeholder: String
    @Binding var value: String
    var keyboardType: UIKeyboardType = .default
    var isDisabled: Bool = false
    var onChanged: (() -> Void)?
    var onEditingEnded: (() -> Void)?

    var body: some View {
        XenditLabeledField(label: label, spacing: Spacing.s3) {
            TextField(placeholder, text: $value)
                .font(.labelLgRegular)
                .keyboardType(keyboardType)
                .disabled(isDisabled)
                .padding(.horizontal, Spacing.s3)
                .frame(height: 44)
                .xenditFieldBorder()
                .onChange(of: value) { _ in onChanged?() }
                .onSubmit { onEditingEnded?() }
        }
    }
}
