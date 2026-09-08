//
//  XenditBarcodeView.swift
//  XenditComponents
//
//  Created by Ahmad X on 06/07/2026.
//

import SwiftUI

struct XenditBarcodeView: View {
    let action: PaymentAction
    let businessName: String?
    let channelName: String
    let channelLogoUrl: String?
    let amount: Decimal?
    let currency: String?
    let locale: String
    var showSimulateButton: Bool = false
    var brandColor: String = ""
    let onDismiss: () -> Void
    let onPaymentMade: () -> Void

    @State private var isSharing = false
    @State private var toastMessage: String?

    private var strings: XenditStrings { XenditStrings(locale: locale) }

    private var barcodeImage: UIImage? {
        let a = XenditComponents.appearance
        return BarcodeGenerator.generate(
            from: action.value,
            foreground: a.qrForegroundColor ?? .black,
            background: a.qrBackgroundColor ?? .white
        )
    }

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
                barcodeCard(appearance: a)
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
        .sheet(isPresented: $isSharing) {
            if let img = barcodeImage {
                ActivityViewController(activityItems: [img])
            }
        }
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
    }

    // MARK: - Title

    private func titleSection(appearance: XenditAppearance) -> some View {
        VStack(spacing: Spacing.s1) {
            let title = action.title?.isEmpty == false ? action.title! : channelName
            Text(title)
                .font(.headingH3)
                .foregroundColor(appearance.resolvedText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            if let subtitle = action.subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.bodyMd)
                    .foregroundColor(appearance.resolvedTextSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Barcode card

    private func barcodeCard(appearance: XenditAppearance) -> some View {
        ActionDetailCard(subtitle: action.subtitle, brandColor: brandColor) {
            VStack(spacing: Spacing.s3) {
                VStack(spacing: 0) {
                    barcodeImageBox(appearance: appearance)
                    
                    Text(action.value)
                        .font(.labelMdSemiBold)
                        .foregroundColor(appearance.resolvedText)
                        .multilineTextAlignment(.center)
                }

                Button(action: downloadBarcode) {
                    Text(strings.string(for: .actionBarcodeDownloadBarcode))
                        .font(.labelMdSemiBold)
                        .foregroundColor(appearance.resolvedText)
                        .padding(.vertical, Spacing.s2)
                        .padding(.horizontal, Spacing.s4)
                        .overlay(
                            RoundedRectangle(cornerRadius: appearance.resolvedRadius)
                                .stroke(appearance.resolvedBorder, lineWidth: 1)
                        )
                }
                .disabled(barcodeImage == nil)

                if let formatted = formattedAmount {
                    VStack(spacing: 2) {
                        Text(strings.string(for: .actionBarcodeAmountToPay))
                            .font(InterFont.captionRegular)
                            .foregroundColor(appearance.resolvedTextSecondary)
                        Text(formatted)
                            .font(.labelMdSemiBold)
                            .foregroundColor(appearance.resolvedText)
                    }
                    .frame(maxWidth: .infinity)
                }

                HStack(alignment: .top, spacing: Spacing.s4) {
                    VStack(spacing: 2) {
                        Text(strings.string(for: .actionBarcodePaymentCode))
                            .font(InterFont.captionRegular)
                            .foregroundColor(appearance.resolvedTextSecondary)
                        Text(action.value)
                            .font(.labelMdSemiBold)
                            .foregroundColor(appearance.resolvedText)
                    }
                    .frame(maxWidth: .infinity)

                    if let name = businessName, !name.isEmpty {
                        VStack(spacing: 2) {
                            Text(strings.string(for: .actionBarcodeSeller))
                                .font(InterFont.captionRegular)
                                .foregroundColor(appearance.resolvedTextSecondary)
                            Text(name)
                                .font(.labelMdSemiBold)
                                .foregroundColor(appearance.resolvedText)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .multilineTextAlignment(.center)

                if showSimulateButton {
                    simulateSection(appearance: appearance)
                }
            }
            .padding(Spacing.s4)
        }
    }

    @ViewBuilder
    private func barcodeImageBox(appearance: XenditAppearance) -> some View {
        if let img = barcodeImage {
            Image(uiImage: img)
                .resizable()
                .frame(maxWidth: .infinity)
                .frame(height: 160)
        } else {
            Text(strings.string(for: .actionQrCodeUnableToGenerate))
                .font(.bodyMd)
                .foregroundColor(appearance.resolvedDanger)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
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
    }

    // MARK: - Footer

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

    private func footerText(appearance: XenditAppearance) -> some View {
        Text(strings.string(for: .actionPaymentConfirmationInstructions))
            .font(.bodyMd)
            .foregroundColor(appearance.resolvedTextSecondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

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

    private func downloadBarcode() {
        guard barcodeImage != nil else {
            withAnimation { toastMessage = strings.string(for: .actionQrCodeUnableToGenerate) }
            return
        }
        isSharing = true
    }
}
