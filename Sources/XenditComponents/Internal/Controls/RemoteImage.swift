//
//  RemoteImage.swift
//  XenditComponents
//
//  Created by Ahmad X on 28/04/2026.
//

import SwiftUI

/// Renders a remote image from a URL, automatically routing to SVGImage for .svg
/// URLs and AsyncImage for all other formats.
struct RemoteImage: View {
    let url: URL?

    var body: some View {
        if url?.isSVG == true {
            SVGImage(url: url)
                .scaledToFit()
        } else {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Color.gray.opacity(0.15)
            }
        }
    }
}
