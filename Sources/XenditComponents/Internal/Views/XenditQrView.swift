//
//  XenditQrView.swift
//  XenditComponents
//
//  Created by Ahmad X on 02/05/2026.
//

import SwiftUI

struct XenditQrView: View {
    let action: PaymentAction
    let channelName: String
    let amount: Double?
    let currency: String?
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)

            VStack(spacing: 8) {
                Text(action.title ?? "Scan QR Code")
                    .font(.headline)
                if let subtitle = action.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            if let url = URL(string: action.value) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .interpolation(.none)
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 200, height: 200)
                .padding()
                .background(XenditComponents.appearance.resolvedQrBackground)
                .cornerRadius(12)
                .shadow(radius: 2)
            }

            if let amount = amount, let currency = currency {
                VStack(spacing: 4) {
                    Text("Amount to Pay")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(currency) \(amount, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }

            Spacer()

            Text("Please do not close this screen until the payment is complete.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical)
    }
}
