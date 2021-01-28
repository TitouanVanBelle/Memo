//
//  RemindersView.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 04.01.21.
//

import SwiftUI

struct RemindersList: View {

    let reminders: [Reminder]

    let onToggle: (Reminder) -> Void
    let onDelete: (Reminder) -> Void
    let onTap: (Reminder) -> Void

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 8) {
            ForEach(reminders) { reminder in
                ReminderCell(
                    reminder: reminder,
                    onToggle: { onToggle(reminder) },
                    onDelete: { onDelete(reminder) }
                ).onTapGesture {
                    onTap(reminder)
                }
            }
        }
    }
}
