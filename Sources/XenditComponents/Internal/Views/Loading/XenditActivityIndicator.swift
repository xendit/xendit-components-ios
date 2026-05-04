//
//  XenditActivityIndicator.swift
//  XenditComponents
//
//  Created by Ahmad X on 28/04/2026.
//

import SwiftUI

struct XenditActivityIndicator: UIViewRepresentable {
    var style: UIActivityIndicatorView.Style = .medium
    var color: UIColor = .white

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: style)
        indicator.color = color
        return indicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        uiView.startAnimating()
    }
}
