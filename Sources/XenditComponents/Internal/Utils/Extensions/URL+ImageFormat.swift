//
//  URL+ImageFormat.swift
//  XenditComponents
//
//  Created by Ahmad X on 28/04/2026.
//

import Foundation

extension URL {
    /// Returns true when the URL path ends with `.svg` (case-insensitive).
    var isSVG: Bool { pathExtension.lowercased() == "svg" }
}
