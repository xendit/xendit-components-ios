//
//  DateFormatter+Extension.swift
//  XenditComponents
//
//  Created by Ahmad X on 07/04/2026.
//

import Foundation

extension DateFormatter {
    convenience init(calendar: Calendar) {
        self.init()
        self.calendar = calendar
    }
}

