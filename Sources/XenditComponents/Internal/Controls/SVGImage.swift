//
//  SVGImage.swift
//  XenditComponents
//
//  Created by Ahmad X on 10/04/2026.
//

import Kingfisher
import SwiftUI

/// Wraps SVGImageProcessor to guarantee it runs on the main thread.
/// MacawView is a UIKit view — UIView operations must happen on the main thread.
private struct MainThreadSVGProcessor: ImageProcessor {
    let identifier = "co.xendit.macaw.mainthread.v1"
    private let inner = SVGImageProcessor()

    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        if Thread.isMainThread {
            return inner.process(item: item, options: options)
        }
        var image: KFCrossPlatformImage?
        DispatchQueue.main.sync { image = inner.process(item: item, options: options) }
        return image
    }
}

struct SVGImage: View {
    private let url: URL?

    init(url: URL?) {
        self.url = url
    }

    var body: some View {
        KFImage(url)
            .setProcessor(MainThreadSVGProcessor())
            .resizable()
    }
}
