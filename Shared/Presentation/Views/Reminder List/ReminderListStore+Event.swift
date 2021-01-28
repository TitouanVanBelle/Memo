//
//  ReminderListStore+Event.swift
//  Memo (iOS)
//
//  Created by Titouan Van Belle on 28.01.21.
//

import Foundation

extension RemindersStore {
    enum Event {
        case loadReminders
        case onRemindersLoaded([Reminder])
        case onFailedToLoadReminders(Error)

        case toggleReminder(Reminder)
        case onReminderToggled(Reminder)
        case onFailedToToggleReminder(Error)

        case deleteReminder(Int, Reminder)
        case onReminderDeleted(Int, Reminder)
        case onFailedToDeleteReminder(Error)

        case selectReminder(Reminder)

        case dismissError
    }
}

