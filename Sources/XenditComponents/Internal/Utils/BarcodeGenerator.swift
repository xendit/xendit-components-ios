//
//  BarcodeGenerator.swift
//  XenditComponents
//
//  Created by Ahmad X on 06/07/2026.
//

import CoreImage
import UIKit

struct BarcodeGenerator {
    static func generate(
        from string: String,
        foreground: UIColor = .black,
        background: UIColor = .white
    ) -> UIImage? {
        guard let data = string.data(using: .ascii),
              let filter = CIFilter(name: "CICode128BarcodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(0, forKey: "inputQuietSpace")
        guard let rawImage = filter.outputImage else { return nil }

        let scale: CGFloat = 3.0
        let scaled = rawImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let colorFilter = CIFilter(name: "CIFalseColor") else {
            let ctx = CIContext()
            guard let cg = ctx.createCGImage(scaled, from: scaled.extent) else { return nil }
            return UIImage(cgImage: cg)
        }
        colorFilter.setValue(scaled, forKey: "inputImage")
        colorFilter.setValue(CIColor(color: foreground), forKey: "inputColor0")
        colorFilter.setValue(CIColor(color: background), forKey: "inputColor1")
        guard let colored = colorFilter.outputImage else { return nil }

        let ctx = CIContext()
        guard let cg = ctx.createCGImage(colored, from: colored.extent) else { return nil }
        return UIImage(cgImage: cg)
    }
}
