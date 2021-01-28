//
//  ReminderList.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 04.01.21.
//

import SwiftUI

struct ReminderList: View {

    let sections: [[Reminder]]
    let shouldShowSectionTitles: Bool

    let onToggle: (Reminder) -> Void
    let onDelete: (Int, Reminder) -> Void
    let onTap: (Reminder) -> Void

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 8) {
            ForEach(0..<sections.count, id: \.self) { index in
                VStack(alignment: .leading) {
                    if shouldShowSectionTitles {
                        sectionTitle(for: sections[index][0].date)
                    }

                    ForEach(sections[index]) { reminder in
                        ReminderCell(
                            reminder: reminder,
                            onToggle: { onToggle(reminder) },
                            onDelete: { onDelete(index, reminder) }
                        ).onTapGesture {
                            onTap(reminder)
                        }
                    }
                }
                .padding(.bottom, 10)
            }
        }
    }

    func sectionTitle(for date: Date?) -> some View {
        Text(date == nil ? "Unscheduled" : DateFormatter.relativeDateFormatter.string(from: date!))
            .font(Daisy.font.largeTitle)
            .foregroundColor(Daisy.color.primaryForeground)
    }
}
