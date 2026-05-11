//
//  XenditSkeletonView.swift
//  XenditComponents
//
//  Created by Ahmad X on 03/05/2026.
//

import SwiftUI

struct XenditSkeletonView: View {
    @State private var shimmerPhase: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            cardSkeleton
                .padding(.horizontal, Spacing.s4)
                .padding(.top, Spacing.s4)

            buttonSkeleton
                .padding(.horizontal, Spacing.s4)
                .padding(.top, Spacing.s4)

            Spacer()
        }
        .onAppear {
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                shimmerPhase = 1
            }
        }
    }

    private var cardSkeleton: some View {
        VStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { index in
                skeletonRow(textWidth: index == 0 ? 180 : 140)
                if index < 2 {
                    Divider()
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: XenditComponents.appearance.resolvedRadius)
                .stroke(XenditComponents.appearance.resolvedBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: XenditComponents.appearance.resolvedRadius))
    }

    private func skeletonRow(textWidth: CGFloat) -> some View {
        HStack(spacing: Spacing.s3) {
            skeletonBlock(width: 28, height: 28, cornerRadius: 4)
            skeletonBlock(width: textWidth, height: 16, cornerRadius: 8)
            Spacer()
        }
        .padding(Spacing.s4)
    }

    private var buttonSkeleton: some View {
        skeletonBlock(width: .infinity, height: 52, cornerRadius: XenditComponents.appearance.resolvedRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
    }

    private func skeletonBlock(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> some View {
        GeometryReader { geo in
            let resolvedWidth = width == .infinity ? geo.size.width : width
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color(UIColor.systemGray5))
                .overlay(shimmerOverlay(in: geo))
                .frame(width: resolvedWidth, height: height)
        }
        .frame(width: width == .infinity ? nil : width, height: height)
        .frame(maxWidth: width == .infinity ? .infinity : nil)
    }

    private func shimmerOverlay(in geo: GeometryProxy) -> some View {
        let width = geo.size.width
        let gradient = LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .white.opacity(0.5), location: 0.5),
                .init(color: .clear, location: 1)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        return gradient
            .frame(width: width * 2)
            .offset(x: shimmerPhase * width * 2 - width)
            .clipped()
    }
}
