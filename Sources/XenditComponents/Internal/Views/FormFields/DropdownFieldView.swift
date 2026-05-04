//
//  DropdownFieldView.swift
//  XenditComponents
//
//  Created by Ahmad X on 01/05/2026.
//

import SwiftUI
import UIKit

struct DropdownFieldView: View {
    let label: String
    let placeholder: String
    let options: [Option]
    @Binding var value: String
    var isDisabled: Bool = false
    var onChanged: (() -> Void)?

    struct Option: Identifiable {
        var id: String { value }
        let label: String
        let value: String
        let subtitle: String?
    }

    private var selectedLabel: String {
        options.first(where: { $0.value == value })?.label ?? placeholder
    }

    var body: some View {
        XenditLabeledField(label: label) {
            Menu {
                ForEach(options) { option in
                    Button(action: {
                        value = option.value
                        onChanged?()
                    }) {
                        Text(option.label)
                    }
                }
            } label: {
                HStack {
                    Text(selectedLabel)
                        .foregroundColor(value.isEmpty ? Color(UIColor.placeholderText) : .primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding(.horizontal, Spacing.s3)
                .frame(height: 44)
                .xenditFieldBorder()
            }
            .disabled(isDisabled)
        }
    }
}
