//
//  CreditCardNumberFieldView.swift
//  XenditComponents
//
//  Created by Ahmad X on 02/05/2026.
//

import SwiftUI
import UIKit

struct CreditCardNumberFieldView: View {
    let label: String
    let placeholder: String
    var brands: [String] = []
    @Binding var value: String
    var isDisabled: Bool = false
    var cardType: CreditCardType? = nil
    var onChanged: (() -> Void)?
    var onEditingEnded: (() -> Void)?

    // Brand assets to show when the field is empty (no card number entered yet).
    private var visibleBrandAssets: [String] {
        guard value.isEmpty else { return [] }
        return brands.compactMap { CreditCardType(rawValue: $0)?.localAssetName }
    }

    // Right-side icon area width: used to offset the text field so text doesn't overlap the badges.
    private var trailingIconWidth: CGFloat {
        if !visibleBrandAssets.isEmpty {
            // Each badge: 36pt logo + 4pt inner padding + 2pt border = 42pt; 4pt gap between badges; 10pt from edge.
            return CGFloat(visibleBrandAssets.count) * 42 + CGFloat(visibleBrandAssets.count - 1) * 4 + 10
        }
        return cardType?.localAssetName != nil ? 46 : 0
    }

    var body: some View {
        XenditLabeledField(label: label) {
            ZStack(alignment: .trailing) {
                XenditTextField(
                    text: $value,
                    placeholder: placeholder,
                    isDisabled: isDisabled,
                    keyboardType: .numberPad,
                    uiFont: XenditComponents.appearance.fontFamily?.regular,
                    characterFilter: \.isNumber,
                    maxLength: 16,
                    transform: { text in
                        let digits = String(text.filter(\.isNumber).prefix(16))
                        return (display: formatCardNumber(digits), stored: digits)
                    },
                    onChanged: onChanged,
                    onEditingEnded: onEditingEnded
                )
                .padding(.horizontal, Spacing.s3)
                .padding(.trailing, trailingIconWidth)
                .frame(height: 44)
                .xenditFieldBorder()

                trailingBadge
            }
        }
    }

    @ViewBuilder
    private var trailingBadge: some View {
        if !visibleBrandAssets.isEmpty {
            // Multiple brand logos — shown when the field is empty.
            HStack(spacing: 4) {
                ForEach(visibleBrandAssets, id: \.self) { assetName in
                    brandLogo(assetName: assetName)
                }
            }
            .padding(.trailing, Spacing.s3)
        } else if let assetName = cardType?.localAssetName {
            // Single detected card type — shown while the user is typing.
            brandLogo(assetName: assetName)
                .padding(.trailing, Spacing.s3)
        }
    }

    private func brandLogo(assetName: String) -> some View {
        Image(assetName, bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 23.3, height: 16.7)
            .padding(2)
            .overlay {
                RoundedRectangle(cornerRadius: 3.33)
                    .stroke(
                        XenditComponents.appearance.resolvedBorder,
                        lineWidth: 1
                    )
            }
    }
}

private func formatCardNumber(_ digits: String) -> String {
    var result = ""
    for (i, ch) in digits.enumerated() {
        if i > 0 && i % 4 == 0 { result.append(" ") }
        result.append(ch)
    }
    return result
}
