//
//  SVGImage.swift
//  XenditComponents
//
//  Created by Ahmad X on 10/04/2026.
//

import Kingfisher
import SwiftUI

/// Custom Kingfisher processor that parses SVG on the main thread.
/// SVGKit accesses UIScreen.main for PPI calculation, which must happen on the main thread.
/// Using the default background-thread SVGImageProcessor causes an intermittent assertion failure.
/// Wraps Kingfisher's SVGImageProcessor to ensure SVGKit runs on the main thread.
/// SVGKit accesses UIScreen.main for PPI calculation, which requires the main thread.
/// Running it on a background thread causes an intermittent assertion failure on first load.
private struct MainThreadSVGProcessor: ImageProcessor {
    let identifier = "co.xendit.svgk.mainthread"
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
