//
//  TodayStore+Event.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 25.01.21.
//

import Foundation

extension TodayStore {
    enum Event {
        case listenToDateUpdate
        case onDateUpdateOrderReceived

        case fetchRemindersAndSubscribeToChange
        case fetchReminders
        case onRemindersFetched([Reminder])
        case onFailedToFetchReminders(Error)

        case toggleReminder(Reminder)
        case onReminderToggled(Reminder)
        case onFailedToToggleReminder(Error)

        case deleteReminder(Reminder)
        case onReminderDeleted(Reminder)
        case onFailedToDeleteReminder(Error)

        case selectReminder(Reminder)
        case createNewReminder

        case seeAllReminders

        case dismissError
    }
}
