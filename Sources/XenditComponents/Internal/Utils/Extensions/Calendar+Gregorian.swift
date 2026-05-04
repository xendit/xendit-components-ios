//
//  Calendar+Gregorian.swift
//  XenditComponents
//
//  Created by Ahmad X on 07/04/2026.
//

import Foundation

extension Calendar {
    static var gregorian: Calendar { Calendar(identifier: .gregorian) }

    var daysOfWeek: [Date] {
        guard let interval = dateInterval(of: .weekOfYear, for: Date()) else { return [] }
        return generateDates(
            from: interval.start,
            to: interval.end,
            components: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }

    func generateDates(from start: Date, to end: Date, components: DateComponents) -> [Date] {
        var dates = [start]
        enumerateDates(startingAfter: start, matching: components, matchingPolicy: .nextTime) { date, _, stop in
            guard let date = date else { return }
            if date < end {
                dates.append(date)
            } else {
                stop = true
            }
        }
        return dates
    }
}
