//
//  DayViewModifier.swift
//  Yoda (iOS)
//
//  Created by Titouan Van Belle on 13.01.21.
//

import SwiftUI

struct DayViewModifier : ViewModifier {

    @Binding var selectedDate: Date?
    let date: Date

    @ViewBuilder
    func body(content: Content) -> some View {
        if date == selectedDate {
            selectedDayModifier(content)
        } else if date < Date.today {
            pastDayModifier(content)
        } else if date == Date.today {
            todayModifier(content)
        } else {
            futureDayModifier(content)
        }
    }

    func todayModifier(_ content: Content) -> some View {
        content
            .foregroundColor(Daisy.color.primaryForeground)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Daisy.color.quartiaryForeground, lineWidth: 1)
                    .frame(width: 30, height: 30)
            )
    }

    func pastDayModifier(_ content: Content) -> some View {
        content
            .foregroundColor(Daisy.color.secondaryForeground)
    }

    func futureDayModifier(_ content: Content) -> some View {
        content
            .foregroundColor(Daisy.color.primaryForeground)
    }

    func selectedDayModifier(_ content: Content) -> some View {
        content
            .foregroundColor(Daisy.color.white)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Daisy.color.quartiaryForeground)
                    .frame(width: 30, height: 30)
            )
    }
}
