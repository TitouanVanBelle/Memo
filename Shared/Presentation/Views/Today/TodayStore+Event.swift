//
//  TodayStore+Event.swift
//  Yoda (iOS)
//
//  Created by Titouan Van Belle on 25.01.21.
//

import Foundation

extension TodayStore {
    enum Event {
        case loadReminders
        case onRemindersLoaded([Reminder])
        case onFailedToLoadReminders(Error)

        case toggleReminder(Reminder)
        case onReminderToggled(Reminder)
        case onFailedToToggleReminder(Error)

        case deleteReminder(Reminder)
        case onReminderDeleted(Reminder)
        case onFailedToDeleteReminder(Error)

        case selectReminder(Reminder)
        case createNewReminder

        case dismissError
    }
}
