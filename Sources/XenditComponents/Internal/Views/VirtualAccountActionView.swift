//
//  VirtualAccountActionView.swift
//  XenditComponents
//
//  Created by Ahmad X on 03/07/2026.
//

import SwiftUI

struct VirtualAccountActionView: View {
    let action: PaymentAction
    let businessName: String?
    let channelName: String
    let channelLogoUrl: String?
    let amount: Decimal?
    let currency: String?
    let locale: String
    var showSimulateButton: Bool = false
    var brandColor: String = ""
    var onCopy: ((String) -> Void)?
    let onDismiss: () -> Void
    let onPaymentMade: () -> Void

    @State private var toastMessage: String?

    private var strings: XenditStrings { XenditStrings(locale: locale) }

    private var formattedAmount: String? {
        guard let amount, let currency, amount > 0 else { return nil }
        return AmountFormat.format(amount: amount, currency: currency)
    }

    var body: some View {
        let a = XenditComponents.appearance
        ScrollView {
            VStack(spacing: Spacing.s4) {
                headerRow(appearance: a)
                titleSection(appearance: a)
                detailCard(appearance: a)
                if let tabs = action.instructions, !tabs.isEmpty {
                    VAInstructionsView(tabs: tabs, appearance: a)
                }
                paymentMadeButton(appearance: a)
                footerText(appearance: a)
            }
            .padding(.horizontal, Spacing.s4)
            .padding(.vertical, Spacing.s6)
        }
        .background(a.resolvedBackground)
        .overlay(toastOverlay, alignment: .bottom)
    }

    // MARK: - Header

    private func headerRow(appearance: XenditAppearance) -> some View {
        ZStack {
            if let urlStr = channelLogoUrl, !urlStr.isEmpty {
                RemoteImage(url: URL(string: urlStr))
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
            }
            HStack {
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(appearance.resolvedTextSecondary)
                }
            }
        }
        .frame(height: 28)
    }

    // MARK: - Title

    private func titleSection(appearance: XenditAppearance) -> some View {
        VStack(spacing: Spacing.s2) {
            let title = action.title?.isEmpty == false
                ? action.title!
                : strings.string(for: .actionVaTransferTo, replacements: ["channelName": channelName])
            Text(title)
                .font(.headingH3)
                .foregroundColor(appearance.resolvedText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

        }
    }

    // MARK: - Combined detail card

    private func detailCard(appearance: XenditAppearance) -> some View {
        ActionDetailCard(subtitle: action.subtitle, brandColor: brandColor) {
            vaNumberRow(appearance: appearance)

            if formattedAmount != nil {
                Divider()
                amountRow(appearance: appearance)
            }

            if showSimulateButton {
                Divider()
                simulateSection(appearance: appearance)
            }
        }
    }

    private func vaNumberRow(appearance: XenditAppearance) -> some View {
        HStack(alignment: .center, spacing: Spacing.s3) {
            VStack(alignment: .leading, spacing: Spacing.s1) {
                Text(strings.string(for: .actionVaVirtualAccountNumber))
                    .font(InterFont.captionRegular)
                    .foregroundColor(appearance.resolvedTextSecondary)
                Text(action.value)
                    .font(.headingH3)
                    .foregroundColor(appearance.resolvedText)
                if let name = businessName, !name.isEmpty {
                    Text(name)
                        .font(InterFont.captionRegular)
                        .foregroundColor(appearance.resolvedTextSecondary)
                }
            }
            Spacer()
            copyButton(value: action.value, label: strings.string(for: .actionVaCopyNumber), fieldName: "va_number", appearance: appearance)
        }
        .padding(Spacing.s4)
    }

    private func amountRow(appearance: XenditAppearance) -> some View {
        HStack(alignment: .center, spacing: Spacing.s3) {
            VStack(alignment: .leading, spacing: Spacing.s1) {
                Text(strings.string(for: .actionVaAmountToPay))
                    .font(InterFont.captionRegular)
                    .foregroundColor(appearance.resolvedTextSecondary)
                if let formatted = formattedAmount {
                    Text(formatted)
                        .font(.headingH3)
                        .foregroundColor(appearance.resolvedText)
                }
            }
            Spacer()
            copyButton(
                value: amount?.description ?? "",
                label: strings.string(for: .actionVaCopyAmount),
                fieldName: "amount",
                appearance: appearance
            )
        }
        .padding(Spacing.s4)
    }

    private func simulateSection(appearance: XenditAppearance) -> some View {
        VStack(spacing: Spacing.s2) {
            Button(action: onPaymentMade) {
                Text(strings.string(for: .actionSimulatePayment))
                    .font(.labelMdSemiBold)
                    .foregroundColor(appearance.resolvedText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(appearance.resolvedBackground)
                    .cornerRadius(appearance.resolvedRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: appearance.resolvedRadius)
                            .stroke(appearance.resolvedBorder, lineWidth: 1)
                    )
            }
            Text(strings.string(for: .actionSimulatePaymentInstructions))
                .font(InterFont.captionRegular)
                .foregroundColor(appearance.resolvedTextSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(Spacing.s4)
    }

    // MARK: - Copy button

    private func copyButton(value: String, label: String, fieldName: String, appearance: XenditAppearance) -> some View {
        Button(action: { copyToClipboard(value, fieldName: fieldName) }) {
            Text(label)
                .font(.labelMdSemiBold)
                .foregroundColor(appearance.resolvedText)
                .padding(.vertical, Spacing.s2)
                .padding(.horizontal, Spacing.s3)
                .background(appearance.resolvedBackground)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(appearance.resolvedBorder, lineWidth: 1))
        }
    }

    // MARK: - Payment made button

    private func paymentMadeButton(appearance: XenditAppearance) -> some View {
        Button(action: onPaymentMade) {
            Text(strings.string(for: .actionPaymentMade))
                .font(.bodyEmphasized)
                .foregroundColor(appearance.resolvedText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(appearance.resolvedBackground)
                .cornerRadius(appearance.resolvedRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: appearance.resolvedRadius)
                        .stroke(appearance.resolvedBorder, lineWidth: 1)
                )
        }
    }

    // MARK: - Footer

    private func footerText(appearance: XenditAppearance) -> some View {
        Text(strings.string(for: .actionPaymentConfirmationInstructions))
            .font(.bodyMd)
            .foregroundColor(appearance.resolvedTextSecondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Toast

    @ViewBuilder
    private var toastOverlay: some View {
        if let message = toastMessage {
            Text(message)
                .font(.captionRegular)
                .foregroundColor(.white)
                .padding(.horizontal, Spacing.s4)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.75))
                .cornerRadius(Spacing.s2)
                .padding(.bottom, Spacing.s6)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation { toastMessage = nil }
                    }
                }
        }
    }

    // MARK: - Actions

    private func copyToClipboard(_ value: String, fieldName: String) {
        UIPasteboard.general.string = value
        onCopy?(fieldName)
        withAnimation { toastMessage = strings.string(for: .copiedToClipboard) }
    }
}

// MARK: - VA Instructions renderer

struct VAInstructionsView: View {
    let tabs: [PaymentResponse.InstructionsTab]
    let appearance: XenditAppearance

    @State private var selectedTabIndex: Int = 0

    private var effectiveIndex: Int {
        selectedTabIndex.coerceIn(0, max(tabs.count - 1, 0))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if tabs.count > 1 {
                tabBar
                Divider()
            }

            if let tab = tabs.getOrNil(effectiveIndex) {
                instructionContent(tab: tab)
                    .padding(Spacing.s4)
            }
        }
        .background(appearance.resolvedBackground)
        .cornerRadius(appearance.resolvedRadius)
        .overlay(
            RoundedRectangle(cornerRadius: appearance.resolvedRadius)
                .stroke(appearance.resolvedBorder, lineWidth: 1)
        )
    }

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    Button(action: { selectedTabIndex = index }) {
                        VStack(spacing: 0) {
                            Text(tab.title)
                                .font(effectiveIndex == index ? InterFont.labelSmBold : InterFont.labelSmRegular)
                                .foregroundColor(
                                    effectiveIndex == index
                                        ? appearance.resolvedPrimary
                                        : appearance.resolvedTextSecondary
                                )
                                .padding(.horizontal, Spacing.s4)
                                .padding(.vertical, Spacing.s3)
                            Rectangle()
                                .fill(effectiveIndex == index ? appearance.resolvedPrimary : Color.clear)
                                .frame(height: 2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private func instructionContent(tab: PaymentResponse.InstructionsTab) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s3) {
            ForEach(Array(tab.content.enumerated()), id: \.offset) { index, content in
                InstructionBlockView(number: index + 1, content: content, appearance: appearance)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Single numbered instruction block

struct InstructionBlockView: View {
    let number: Int
    let content: PaymentResponse.InstructionsContent
    let appearance: XenditAppearance

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.s2) {
            Text("\(number).")
                .font(InterFont.bodyMd)
                .foregroundColor(appearance.resolvedText)

            contentBody
        }
    }

    @ViewBuilder
    private var contentBody: some View {
        switch content {
        case .step(let step):
            stepView(step)
        case .nested(let items):
            VStack(alignment: .leading, spacing: Spacing.s2) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    switch item {
                    case .string(let text):
                        Text(parseBoldTags(text))
                            .font(InterFont.captionRegular)
                            .foregroundColor(appearance.resolvedTextSecondary)
                    case .step(let step):
                        stepView(step)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func stepView(_ step: PaymentResponse.InstructionsStep) -> some View {
        switch step {
        case .text(let text):
            Text(parseBoldTags(text))
                .font(InterFont.bodyMd)
                .foregroundColor(appearance.resolvedText)
        case .bullets(let items):
            VStack(alignment: .leading, spacing: Spacing.s1) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: Spacing.s1) {
                        Text("•")
                            .font(InterFont.bodyMd)
                            .foregroundColor(appearance.resolvedText)
                        Text(parseBoldTags(item))
                            .font(InterFont.bodyMd)
                            .foregroundColor(appearance.resolvedText)
                    }
                }
            }
        case .image(let src, let height, _):
            RemoteImage(url: URL(string: src))
                .frame(height: CGFloat(height))
                .frame(maxWidth: .infinity)
        case .form(let heading, let fields):
            VStack(alignment: .leading, spacing: Spacing.s1) {
                if let heading, !heading.isEmpty {
                    Text(parseBoldTags(heading))
                        .font(InterFont.labelSmBold)
                        .foregroundColor(appearance.resolvedText)
                }
                ForEach(fields, id: \.label) { field in
                    HStack {
                        Text(parseBoldTags(field.label))
                            .font(InterFont.captionRegular)
                            .foregroundColor(appearance.resolvedTextSecondary)
                        Spacer()
                        Text(parseBoldTags(field.value))
                            .font(InterFont.captionRegular)
                            .foregroundColor(appearance.resolvedText)
                    }
                }
            }
        case .table(let headers, let rows):
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    ForEach(headers, id: \.self) { header in
                        Text(header)
                            .font(InterFont.labelSmBold)
                            .foregroundColor(appearance.resolvedText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    HStack {
                        ForEach(Array(row.enumerated()), id: \.offset) { _, cell in
                            Text(cell)
                                .font(InterFont.captionRegular)
                                .foregroundColor(appearance.resolvedTextSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        case .unknown:
            EmptyView()
        }
    }
}

// MARK: - HTML bold-tag parser

/// Converts `<b>…</b>` and `<strong>…</strong>` markup to a SwiftUI `AttributedString`
/// with bold weight, inheriting the parent `Text`'s font for all other characters.
/// Mirrors Android's `parseBoldTags()` in `PaymentInstructionsContent.kt`.
internal func parseBoldTags(_ text: String) -> AttributedString {
    let pattern = try? NSRegularExpression(
        pattern: "<(b|strong)>(.*?)</(b|strong)>",
        options: [.caseInsensitive, .dotMatchesLineSeparators]
    )
    var result = AttributedString()
    var currentIndex = text.startIndex
    let matches = pattern?.matches(in: text, range: NSRange(text.startIndex..., in: text)) ?? []

    for match in matches {
        guard let fullRange = Range(match.range, in: text),
              let innerRange = Range(match.range(at: 2), in: text) else { continue }

        if currentIndex < fullRange.lowerBound {
            result += AttributedString(String(text[currentIndex..<fullRange.lowerBound]))
        }

        var bold = AttributedString(String(text[innerRange]))
        bold.inlinePresentationIntent = .stronglyEmphasized
        result += bold

        currentIndex = fullRange.upperBound
    }

    if currentIndex < text.endIndex {
        result += AttributedString(String(text[currentIndex...]))
    }

    return result
}

// MARK: - Array helpers

extension Array {
    func getOrNil(_ index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}

extension Int {
    func coerceIn(_ min: Int, _ max: Int) -> Int {
        Swift.max(min, Swift.min(self, max))
    }
}
