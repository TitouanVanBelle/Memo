//
//  MonthView.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 09.01.21.
//

import SwiftUI

struct MonthView: View {

    @Environment(\.calendar) var calendar

    @Binding var selectedDate: Date?

    let month: Date

    init(month: Date, selectedDate: Binding<Date?>) {
        self.month = month
        self._selectedDate = selectedDate
    }

    private var weeks: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else {
            return []
        }
        
        return calendar.generateDates(
            inside: monthInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0, weekday: 1)
        )
    }

    var body: some View {
        VStack {
            header
            days
            Spacer()
        }
    }
}

// MARK: UI

fileprivate extension MonthView {
    var header: some View {
        Text(DateFormatter.monthAndYear.string(from: month))
            .font(Daisy.font.largeTitle)
            .padding()
    }

    var days: some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
            ForEach(DateFormatter.weekDays, id: \.self) { day in
                Text(day).id(day)
                    .font(Daisy.font.smallBodyBold)
                    .textCase(.uppercase)
                    .foregroundColor(Daisy.color.secondaryForeground)
            }
            ForEach(days(in: month), id: \.self) { date in
                if calendar.isDate(date, equalTo: month, toGranularity: .month) {
                    DayView(selectedDate: $selectedDate, date: date)
                } else {
                    Color.clear
                }
            }
        }
    }
}

// MARK: Helpers

fileprivate extension MonthView {
    func days(in month: Date) -> [Date] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: month),
            let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
            let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end)
        else { return [] }
        return calendar.generateDates(
            inside: DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end),
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
}

struct MonthView_Previews: PreviewProvider {
    @Environment(\.calendar) static var calendar

    static var previews: some View {
        MonthView(
            month: Date(),
            selectedDate: .constant(Date())
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
