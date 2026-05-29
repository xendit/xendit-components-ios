//
//  SVGImageProcessor.swift
//  XenditComponents
//
//  Created by Ahmad X on 10/04/2026.
//

import Kingfisher
import Macaw
import UIKit

/// Kingfisher ImageProcessor that renders SVG data to a UIImage using Macaw.
/// Must be called on the main thread — UIView operations (MacawView) require it.
/// SVGImage dispatches to the main thread before calling this processor.
public struct SVGImageProcessor: ImageProcessor {
    public let identifier = "co.xendit.macaw.svg.v1"

    public init() {}

    public func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let img):
            return img
        case .data(let data):
            guard let text = String(data: data, encoding: .utf8),
                  let node = try? SVGParser.parse(text: text) else { return nil }

            let renderSize: CGSize
            if let b = node.bounds {
                renderSize = CGSize(width: b.w, height: b.h)
            } else {
                renderSize = CGSize(width: 100, height: 100)
            }

            let view = MacawView(frame: CGRect(origin: .zero, size: renderSize))
            view.node = node
            view.backgroundColor = .clear
            view.isOpaque = false
            view.layoutIfNeeded()

            let fmt = UIGraphicsImageRendererFormat.default()
            fmt.scale = UIScreen.main.scale  // Match device pixel density (1×/2×/3×) so no upscaling softens colors
            return UIGraphicsImageRenderer(size: renderSize, format: fmt).image { ctx in
                view.layer.render(in: ctx.cgContext)
            }
        }
    }
}
