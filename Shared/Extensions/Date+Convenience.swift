//
//  Date+Convenience.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 13.01.21.
//

import Foundation

extension Date {
    static var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: today)!
    }

    static var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    static var tomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: today)!
    }

    var isInPast: Bool {
        self < Date()
    }

    var isBeforeToday: Bool {
        self < .today
    }

    init?(
        year: Int? = nil,
        month: Int? = nil,
        day: Int? = nil,
        hour: Int? = nil,
        minute: Int? = nil,
        second: Int? = nil
    ) {
        let components = DateComponents(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second
        )

        guard let date = Calendar.current.date(from: components) else {
            return nil
        }

        self = date
    }
}
