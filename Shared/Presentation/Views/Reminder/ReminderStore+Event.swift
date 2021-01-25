//
//  ReminderStore+Event.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 25.01.21.
//

import Foundation

extension ReminderStore {
    enum Event {
        case checkNotificationAuthorization
        case onNotificationAuthorizationChecked(Bool)
        case onNotificationAuthorized
        case onNotificationDeclined(Error)

        case createReminder
        case onReminderCreated
        case onFailedToCreateReminder(Error)

        case updateReminder
        case onReminderUpdated
        case onFailedToUpdateReminder(Error)

        case selectDate(Date?)

        case showDatePicker
        case showTimePicker
        case clearBottomView

        case dismissError
    }
}
