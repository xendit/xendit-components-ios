//
//  QrCodeGenerator.swift
//  XenditComponents
//
//  Created by Ahmad X on 29/05/2026.
//

import CoreImage
import UIKit

struct QrCodeGenerator {
    /// Generates a QR code bitmap from a QRIS data string.
    ///
    /// Uses `CIQRCodeGenerator` (CoreImage) with error correction level M and
    /// `CIFalseColor` to apply custom foreground/background colors.
    /// Returns `nil` if the string cannot be encoded.
    static func generate(
        from string: String,
        size: CGFloat,
        foreground: UIColor = .black,
        background: UIColor = .white
    ) -> UIImage? {
        guard let data = string.data(using: .isoLatin1) else { return nil }

        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("M", forKey: "inputCorrectionLevel")
        guard let rawImage = qrFilter.outputImage else { return nil }

        let scale = size / rawImage.extent.width
        let scaledImage = rawImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard
            let colorFilter = CIFilter(name: "CIFalseColor")
        else {
            let ctx = CIContext()
            guard let cg = ctx.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
            return UIImage(cgImage: cg)
        }
        
        let fg = CIColor(color: foreground)
        let bg = CIColor(color: background)

        // inputColor0 = dark pixels (QR modules), inputColor1 = light pixels (background)
        colorFilter.setValue(scaledImage, forKey: "inputImage")
        colorFilter.setValue(fg, forKey: "inputColor0")
        colorFilter.setValue(bg, forKey: "inputColor1")
        guard let colored = colorFilter.outputImage else { return nil }

        let ctx = CIContext()
        guard let cg = ctx.createCGImage(colored, from: colored.extent) else { return nil }
        return UIImage(cgImage: cg)
    }
}
