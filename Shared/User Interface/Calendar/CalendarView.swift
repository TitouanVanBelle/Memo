//
//  CalendarView.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 09.01.21.
//

import Foundation
import SwiftUI
import UIKit


struct CalendarView: View {

    @Environment(\.calendar) var calendar

    @Binding var selectedDate: Date?

    let interval: DateInterval

    init(interval: DateInterval, selectedDate: Binding<Date?>) {
        self.interval = interval
        self._selectedDate = selectedDate
    }

    var body: some View {
        GeometryReader { fullView in
            PageView(
                months.map { month in
                    MonthView(month: month, selectedDate: $selectedDate)
                        .background(Color.clear)
                }
            ).background(Color.clear)
        }
    }
}

fileprivate extension CalendarView {
    var months: [Date] {
        calendar.generateDates(
            inside: interval,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        )
    }
}

struct CalendarView_Previews: PreviewProvider {
    @Environment(\.calendar) static var calendar

    static var year: DateInterval {
        calendar.dateInterval(of: .year, for: Date())!
    }

    static var previews: some View {
        CalendarView(interval: year, selectedDate: .constant(nil))
            .previewLayout(.sizeThatFits)
    }
}

struct PreselectedDateCalendarView_Previews: PreviewProvider {
    @Environment(\.calendar) static var calendar

    static var year: DateInterval {
        calendar.dateInterval(of: .year, for: Date())!
    }

    static var previews: some View {
        CalendarView(interval: year, selectedDate: .constant(nil))
            .previewLayout(.sizeThatFits)
    }
}
