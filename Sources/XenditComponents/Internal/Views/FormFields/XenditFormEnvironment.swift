//
//  XenditFormEnvironment.swift
//  XenditComponents
//
//  Created by Ahmad X on 02/05/2026.
//

import SwiftUI
import UIKit

// When true, individual field views suppress their outer border stroke.
// Used by ChannelFormView to render consecutive joined fields as a single grouped card.
private struct XenditHideFieldBorderKey: EnvironmentKey {
    static let defaultValue = false
}

// When true, individual field views render their border using the danger/error color.
private struct XenditFieldHasErrorKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var xenditHideFieldBorder: Bool {
        get { self[XenditHideFieldBorderKey.self] }
        set { self[XenditHideFieldBorderKey.self] = newValue }
    }

    var xenditFieldHasError: Bool {
        get { self[XenditFieldHasErrorKey.self] }
        set { self[XenditFieldHasErrorKey.self] = newValue }
    }
}

// MARK: - Field border modifier

/// Applies the standard Xendit bordered background (stroke + rounded corners + error/hide states).
/// Replaces the identical effectiveBorderColor + RoundedRectangle block duplicated across all field views.
struct XenditFieldBorderModifier: ViewModifier {
    @Environment(\.xenditHideFieldBorder) private var hideFieldBorder
    @Environment(\.xenditFieldHasError) private var fieldHasError

    private var borderColor: Color {
        if hideFieldBorder { return .clear }
        let a = XenditComponents.appearance
        return fieldHasError ? a.resolvedDanger : a.resolvedBorder
    }

    func body(content: Content) -> some View {
        content.background(
            RoundedRectangle(cornerRadius: XenditComponents.appearance.resolvedRadius)
                .stroke(borderColor, lineWidth: hideFieldBorder ? 0 : 1)
        )
    }
}

extension View {
    func xenditFieldBorder() -> some View {
        modifier(XenditFieldBorderModifier())
    }
}

// MARK: - Labeled field container

/// Standard label + content VStack used by every field view.
struct XenditLabeledField<Content: View>: View {
    let label: String
    var spacing: CGFloat = Spacing.s1
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            if !label.isEmpty {
                Text(label)
                    .font(.labelLgRegular)
                    .foregroundColor(.Text.default)
            }
            content()
        }
    }
}
