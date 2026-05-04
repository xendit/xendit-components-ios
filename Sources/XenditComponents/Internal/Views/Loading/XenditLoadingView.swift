//
//  XenditLoadingView.swift
//  XenditComponents
//
//  Created by Ahmad X on 28/04/2026.
//

import SwiftUI

struct XenditLoadingView: View {
    private static let cardSize: CGFloat = 124
    private static let cardBackground = Color(UIColor(white: 0.12, alpha: 0.7))

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            Group {
                if let custom = XenditComponents.appearance.customLoadingView {
                    custom
                } else {
                    XenditActivityIndicator(style: .large, color: .white)
                        .frame(width: Self.cardSize, height: Self.cardSize)
                        .background(Self.cardBackground)
                        .cornerRadius(CornerRadius.md)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
