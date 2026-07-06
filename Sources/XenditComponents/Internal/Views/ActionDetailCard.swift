//
//  ActionDetailCard.swift
//  XenditComponents
//
//  Created by Ahmad X on 06/07/2026.
//

import SwiftUI

/// Shared card chrome used by VA and barcode action views.
///
/// - With subtitle: colored header band (accent color, white text) wraps the
///   inner content card with a 1pt inset. No border.
/// - Without subtitle: plain card with accent-colored 1pt stroke border.
///
/// Accent resolves from `brandColor` hex, falling back to `appearance.resolvedPrimary`.
struct ActionDetailCard<Content: View>: View {
    let subtitle: String?
    let brandColor: String
    @ViewBuilder let content: () -> Content

    private var hasSubtitle: Bool { subtitle?.isEmpty == false }

    private func accentColor(_ appearance: XenditAppearance) -> Color {
        brandColor.isEmpty ? appearance.resolvedPrimary : Color(hex: brandColor)
    }

    var body: some View {
        let a = XenditComponents.appearance
        VStack(spacing: 0) {
            if let subtitle, !subtitle.isEmpty {
                Text(parseBoldTags(subtitle))
                    .font(.labelMdSemiBold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(Spacing.s2)
            }

            VStack(spacing: 0) {
                content()
            }
            .background(a.resolvedBackground)
            .cornerRadius(hasSubtitle ? a.resolvedRadius : 0)
            .padding(hasSubtitle ? Spacing.s1 : 0)
        }
        .background(hasSubtitle ? accentColor(a) : a.resolvedBackground)
        .cornerRadius(a.resolvedRadius)
        .overlay(
            RoundedRectangle(cornerRadius: a.resolvedRadius)
                .stroke(hasSubtitle ? Color.clear : accentColor(a), lineWidth: 1)
        )
    }
}
