//
//  SVGImageProcessor.swift
//  XenditComponents
//
//  Created by Ahmad X on 10/04/2026.
//

import Kingfisher
import SVGKit
import UIKit

public struct SVGImageProcessor: ImageProcessor {
    public var identifier: String = "co.xendit.webpprocessor"
    public func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case let .image(image):
            return image
        case let .data(data):
            let imsvg = SVGKImage(data: data)
            return imsvg?.uiImage
        }
    }
}
