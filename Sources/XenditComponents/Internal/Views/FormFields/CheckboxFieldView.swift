//
//  CheckboxFieldView.swift
//  XenditComponents
//
//  Created by Ahmad X on 02/05/2026.
//

import SwiftUI

struct CheckboxFieldView: View {
    @Binding var isChecked: Bool
    let isEnabled: Bool
    var locale: String = "en"

    private var strings: XenditStrings {
        XenditStrings(locale: locale)
    }

    var body: some View {
        Button(action: {
            guard isEnabled else { return }
            isChecked.toggle()
        }) {
            HStack(spacing: Spacing.s3) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(isChecked
                        ? (XenditComponents.appearance.resolvedPrimary)
                        : Color.secondary
                    )
                    .font(.title3)

                Text(strings.string(for: .paymentSaveCheckboxLabel))
                    .font(.labelLgRegular)
                    .foregroundColor(isEnabled ? .primary : .secondary)

                Spacer()
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}
