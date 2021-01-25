//
//  DayView.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 09.01.21.
//

import SwiftUI

struct DayView: View {

    @Binding var selectedDate: Date?

    let date: Date

    var body: some View {
        Button(action: {
            if selectedDate == date {
                selectedDate = nil
            } else {
                selectedDate = date
            }
        }) {
            Text(DateFormatter.day.string(from: date))
                .font(Daisy.font.smallBodyBold)
                .frame(width: 22, height: 24)
                .id(date)
                .modifier(DayViewModifier(selectedDate: $selectedDate, date: date))
                .padding(2)
        }.disabled(date < Date.today)
    }
}

struct DayViewYesterday_Previews: PreviewProvider {
    static var previews: some View {
        DayView(selectedDate: .constant(nil), date: .yesterday)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

struct DayViewToday_Previews: PreviewProvider {
    static var previews: some View {
        DayView(selectedDate: .constant(nil), date: .today)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

struct DayViewTomorrow_Previews: PreviewProvider {
    static var previews: some View {
        DayView(selectedDate: .constant(nil), date: .tomorrow)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

struct DayViewSelected_Previews: PreviewProvider {
    static var previews: some View {
        DayView(selectedDate: .constant(.today), date: .today)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
