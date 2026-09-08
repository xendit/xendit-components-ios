//
//  RemoteImage.swift
//  XenditComponents
//
//  Created by Ahmad X on 28/04/2026.
//

import SwiftUI

/// Renders a remote image from a URL, automatically routing to SVGImage for .svg
/// URLs and AsyncImage for all other formats.
/// Falls back to `localFallback` bundle asset when the URL is nil or loading fails.
struct RemoteImage: View {
    let url: URL?
    var localFallback: String? = nil
    var contentMode: ContentMode = .fit

    var body: some View {
        if url?.isSVG == true {
            SVGImage(url: url)
                .scaledToFit()
        } else if let url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                        .aspectRatio(contentMode: contentMode)
                case .failure:
                    fallbackView
                default:
                    Color.gray.opacity(0.15)
                }
            }
        } else {
            fallbackView
        }
    }

    @ViewBuilder
    private var fallbackView: some View {
        if let name = localFallback {
            Image(name, bundle: .module)
                .resizable()
                .scaledToFit()
        } else {
            Color.gray.opacity(0.15)
        }
    }
}
