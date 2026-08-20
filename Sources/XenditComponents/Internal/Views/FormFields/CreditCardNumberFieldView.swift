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
    var brands: [Form.CardBrand] = []
    @Binding var value: String
    var isDisabled: Bool = false
    var cardType: CreditCardType? = nil
    var a11yId: String = ""
    var onChanged: (() -> Void)?
    var onEditingEnded: (() -> Void)?

    private var hasMatchingBrand: Bool {
        cardType.map { type in
            brands.contains { $0.name.caseInsensitiveCompare(type.rawValue) == .orderedSame }
        } ?? false
    }

    // Shown until a matching brand is detected; then the matched brand takes over.
    private var visibleBrands: [Form.CardBrand] {
        guard !hasMatchingBrand else { return [] }
        return brands.filter { !$0.logoUrl.isEmpty || CreditCardType(rawValue: $0.name)?.localAssetName != nil }
    }

    // Right-side icon area width
    private var trailingIconWidth: CGFloat {
        if !visibleBrands.isEmpty {
            return CGFloat(visibleBrands.count) * 42 + CGFloat(visibleBrands.count - 1) * 4 + 10
        }
        return hasMatchingBrand ? 46 : 0
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
                    maxLength: 19,
                    transform: { text in
                        let digits = String(text.filter(\.isNumber).prefix(19))
                        return (display: formatCardNumber(digits), stored: digits)
                    },
                    onChanged: onChanged,
                    onEditingEnded: onEditingEnded,
                    accessibilityIdentifier: a11yId
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
        if !visibleBrands.isEmpty {
            HStack(spacing: 4) {
                ForEach(visibleBrands, id: \.self) { brand in
                    brandLogo(brand: brand)
                }
            }
            .padding(.trailing, Spacing.s3)
        } else if let type = cardType,
                  let matchingBrand = brands.first(where: { $0.name.caseInsensitiveCompare(type.rawValue) == .orderedSame }) {
            brandLogo(brand: matchingBrand)
                .padding(.trailing, Spacing.s3)
        }
    }

    private func brandLogo(brand: Form.CardBrand) -> some View {
        let logoUrl = URL(string: brand.logoUrl)
        let localAsset = CreditCardType(rawValue: brand.name)?.localAssetName
        return RemoteImage(url: logoUrl, localFallback: localAsset)
            .frame(width: 23.3, height: 16.7)
            .padding(2)
            .overlay {
                RoundedRectangle(cornerRadius: 3.33)
                    .stroke(XenditComponents.appearance.resolvedBorder, lineWidth: 1)
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
