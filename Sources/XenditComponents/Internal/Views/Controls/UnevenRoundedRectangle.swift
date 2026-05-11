//
//  UnevenRoundedRectangle.swift
//  XenditComponents
//
//  Created by Ahmad X on 15/04/2026.
//

import Foundation

import SwiftUI

// MARK: - CornerRadii

/// Individual radius for each corner of a rectangle.
struct CornerRadii {
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomLeft: CGFloat
    var bottomRight: CGFloat

    init(
        topLeft: CGFloat = 0,
        topRight: CGFloat = 0,
        bottomLeft: CGFloat = 0,
        bottomRight: CGFloat = 0
    ) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }

    /// All corners the same radius.
    static func all(_ radius: CGFloat) -> CornerRadii {
        CornerRadii(topLeft: radius, topRight: radius, bottomLeft: radius, bottomRight: radius)
    }

    /// Top corners only.
    static func top(_ radius: CGFloat) -> CornerRadii {
        CornerRadii(topLeft: radius, topRight: radius)
    }

    /// Bottom corners only.
    static func bottom(_ radius: CGFloat) -> CornerRadii {
        CornerRadii(bottomLeft: radius, bottomRight: radius)
    }

    /// Left corners only.
    static func left(_ radius: CGFloat) -> CornerRadii {
        CornerRadii(topLeft: radius, bottomLeft: radius)
    }

    /// Right corners only.
    static func right(_ radius: CGFloat) -> CornerRadii {
        CornerRadii(topRight: radius, bottomRight: radius)
    }
}

// MARK: - UnevenRoundedRectangle

/// A rectangle shape with independently configurable corner radii.
/// Works on iOS 15+. On iOS 16+ you can also use the built-in
/// `SwiftUI.UnevenRoundedRectangle` if preferred.
struct UnevenRoundedRectangle: Shape {
    var radii: CornerRadii

    // Convenience initialiser — individual radii.
    init(
        topLeft: CGFloat = 0,
        topRight: CGFloat = 0,
        bottomLeft: CGFloat = 0,
        bottomRight: CGFloat = 0
    ) {
        radii = CornerRadii(
            topLeft: topLeft,
            topRight: topRight,
            bottomLeft: bottomLeft,
            bottomRight: bottomRight
        )
    }

    init(radii: CornerRadii) {
        self.radii = radii
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Clamp each radius so two adjacent radii never exceed the shared edge.
        let tl = min(radii.topLeft,    min(rect.width / 2, rect.height / 2))
        let tr = min(radii.topRight,   min(rect.width / 2, rect.height / 2))
        let bl = min(radii.bottomLeft, min(rect.width / 2, rect.height / 2))
        let br = min(radii.bottomRight,min(rect.width / 2, rect.height / 2))

        let minX = rect.minX
        let minY = rect.minY
        let maxX = rect.maxX
        let maxY = rect.maxY

        // Start at top-left arc end-point (moving right along the top edge).
        path.move(to: CGPoint(x: minX + tl, y: minY))

        // Top edge → top-right corner
        path.addLine(to: CGPoint(x: maxX - tr, y: minY))
        path.addArc(
            center: CGPoint(x: maxX - tr, y: minY + tr),
            radius: tr,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )

        // Right edge → bottom-right corner
        path.addLine(to: CGPoint(x: maxX, y: maxY - br))
        path.addArc(
            center: CGPoint(x: maxX - br, y: maxY - br),
            radius: br,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        // Bottom edge → bottom-left corner
        path.addLine(to: CGPoint(x: minX + bl, y: maxY))
        path.addArc(
            center: CGPoint(x: minX + bl, y: maxY - bl),
            radius: bl,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )

        // Left edge → top-left corner
        path.addLine(to: CGPoint(x: minX, y: minY + tl))
        path.addArc(
            center: CGPoint(x: minX + tl, y: minY + tl),
            radius: tl,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - Animatable

extension UnevenRoundedRectangle: Animatable {
    var animatableData: AnimatablePair<
        AnimatablePair<CGFloat, CGFloat>,
        AnimatablePair<CGFloat, CGFloat>
    > {
        get {
            AnimatablePair(
                AnimatablePair(radii.topLeft, radii.topRight),
                AnimatablePair(radii.bottomLeft, radii.bottomRight)
            )
        }
        set {
            radii.topLeft     = newValue.first.first
            radii.topRight    = newValue.first.second
            radii.bottomLeft  = newValue.second.first
            radii.bottomRight = newValue.second.second
        }
    }
}

// MARK: - View extension

extension View {
    /// Clips and optionally strokes the view using `UnevenRoundedRectangle`.
    func unevenRoundedRectangle(
        radii: CornerRadii,
        fillColor: Color = .clear,
        strokeColor: Color = .clear,
        lineWidth: CGFloat = 1
    ) -> some View {
        let shape = UnevenRoundedRectangle(radii: radii)
        return self
            .clipShape(shape)
            .overlay(shape.stroke(strokeColor, lineWidth: lineWidth))
            .background(shape.fill(fillColor))
    }
}

// MARK: - Preview

#if DEBUG
struct UnevenRoundedRectangle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            // Top corners only
            UnevenRoundedRectangle(radii: .top(24))
                .fill(Color.blue)
                .frame(height: 80)

            // Bottom corners only
            UnevenRoundedRectangle(radii: .bottom(24))
                .fill(Color.green)
                .frame(height: 80)

            // Mixed radii
            UnevenRoundedRectangle(topLeft: 32, topRight: 8, bottomLeft: 8, bottomRight: 32)
                .fill(Color.orange)
                .frame(height: 80)

            // Stroke only
            UnevenRoundedRectangle(topLeft: 0, topRight: 24, bottomLeft: 24, bottomRight: 0)
                .stroke(Color.red, lineWidth: 2)
                .frame(height: 80)

            // Animatable demo — tap to toggle
            AnimatedDemo()
        }
        .padding()
    }

    struct AnimatedDemo: View {
        @State private var toggled = false

        var body: some View {
            UnevenRoundedRectangle(
                topLeft:     toggled ? 40 : 4,
                topRight:    toggled ? 4  : 40,
                bottomLeft:  toggled ? 4  : 40,
                bottomRight: toggled ? 40 : 4
            )
            .fill(Color.purple)
            .frame(height: 80)
            .animation(.spring(), value: toggled)
            .onTapGesture { toggled.toggle() }
        }
    }
}
#endif
