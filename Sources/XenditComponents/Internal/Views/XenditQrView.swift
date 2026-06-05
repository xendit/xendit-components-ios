//
//  XenditQrView.swift
//  XenditComponents
//
//  Created by Ahmad X on 02/05/2026.
//

import SwiftUI

struct XenditQrView: View {
    let action: PaymentAction
    let businessName: String?
    let channelLogoUrl: String?
    let amount: Decimal?
    let currency: String?
    let locale: String
    let onDismiss: () -> Void
    let onPaymentMade: () -> Void

    @State private var isSharing = false
    @State private var toastMessage: String?

    private var strings: XenditStrings { XenditStrings(locale: locale) }

    private var qrImage: UIImage? {
        guard action.isQrString else { return nil }
        let a = XenditComponents.appearance
        return QrCodeGenerator.generate(
            from: action.value,
            size: 297,
            foreground: a.qrForegroundColor ?? .black,
            background: a.qrBackgroundColor ?? .white
        )
    }

    private var nmid: String? {
        guard action.isQrString else { return nil }
        return QrNmidSearcherUtil.getNationalMerchantID(from: action.value)
    }

    private var formattedAmount: String? {
        guard let amount, let currency, amount > 0 else { return nil }
        return AmountFormat.format(amount: amount, currency: currency)
    }

    var body: some View {
        let a = XenditComponents.appearance
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.s4) {
                    headerRow(appearance: a)
                    scanToPayTitle(appearance: a)
                    contentCard(appearance: a)
                    paymentMadeButton(appearance: a)
                    footerText(appearance: a)
                }
                .padding(.horizontal, Spacing.s4)
                .padding(.vertical, Spacing.s6)
            }
            .background(a.resolvedBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            .padding(.horizontal, Spacing.s4)
            .padding(.vertical, Spacing.s6)
        }
        .sheet(isPresented: $isSharing) {
            if let img = qrImage {
                ActivityViewController(activityItems: [img])
            }
        }
        .overlay(toastOverlay, alignment: .bottom)
    }

    // MARK: - Subviews

    private func headerRow(appearance: XenditAppearance) -> some View {
        ZStack {
            RemoteImage(url: URL(string: channelLogoUrl ?? ""))
                .frame(height: 64)
                .frame(maxWidth: .infinity)
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(appearance.resolvedTextSecondary)
                    }
                }
                Spacer()
            }
        }
    }

    private func scanToPayTitle(appearance: XenditAppearance) -> some View {
        let title = action.title?.isEmpty == false ? action.title! : strings.string(for: .actionQrCodeScanToPay)
        return Text(title)
            .font(.headingH3)
            .foregroundColor(appearance.resolvedText)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    private func contentCard(appearance: XenditAppearance) -> some View {
        VStack(spacing: Spacing.s3) {
            // Merchant name
            if let name = businessName, !name.isEmpty {
                Text(name)
                    .font(.bodyEmphasized)
                    .foregroundColor(appearance.resolvedText)
                    .multilineTextAlignment(.center)
            }

            // NMID
            if let nmid {
                Text("NMID: \(nmid)")
                    .font(.bodyEmphasized)
                    .foregroundColor(appearance.resolvedText)
                    .multilineTextAlignment(.center)
            }

            // QR code
            qrCodeBox(appearance: appearance)

            // Download button
            Button(action: downloadQrCode) {
                Text(strings.string(for: .actionQrCodeDownloadQr))
                    .font(.labelMdSemiBold)
                    .foregroundColor(appearance.resolvedText)
                    .padding(.vertical, Spacing.s2)
                    .padding(.horizontal, Spacing.s4)
                    .overlay(
                        RoundedRectangle(cornerRadius: appearance.resolvedRadius)
                            .stroke(appearance.resolvedBorder, lineWidth: 1)
                    )
            }

            // Amount
            if let formatted = formattedAmount {
                Text(formatted)
                    .font(.headingH3)
                    .foregroundColor(appearance.resolvedText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.s4)
        .background(appearance.resolvedBackground)
        .cornerRadius(appearance.resolvedRadius)
        .overlay(
            RoundedRectangle(cornerRadius: appearance.resolvedRadius)
                .stroke(appearance.resolvedBorder, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func qrCodeBox(appearance: XenditAppearance) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: appearance.resolvedRadius)
                .fill(appearance.resolvedQrBackground)
                .frame(maxWidth: .infinity)

            if let img = qrImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
            } else if action.isQrString {
                Text(strings.string(for: .actionQrCodeUnableToGenerate))
                    .font(.bodyMd)
                    .foregroundColor(appearance.resolvedDanger)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
    }

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

    private func downloadQrCode() {
        guard let img = qrImage else {
            withAnimation { toastMessage = strings.string(for: .actionQrCodeUnableToGenerate) }
            return
        }
        isSharing = true
        _ = img // captured by sheet
    }
}

// MARK: - UIActivityViewController bridge

private struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
