//
//  ReminderStore+State.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 25.01.21.
//

import Foundation

extension ReminderStore {
    struct State {
        enum Status {
            case idle
            case checkingNotificationAuthorization
            case requestingAuthorization
            case creatingReminder(ReminderData)
            case schedulingNotification(Reminder)
            case updatingReminder(Reminder, ReminderData)
            case cancellingNotification(Reminder)
        }

        enum BottomViewContent {
            case datePicker
            case timePicker
        }

        var status: Status = .idle

        let reminder: Reminder?

        var focusedTag = 0
        var bottomViewContent: BottomViewContent?
        var keyboardHeight: Double = 301
        var shouldShowEmptyTitleErrorMessage = false
        var shouldShowDateInPastErrorMessage = false
        var shouldDismiss = false
        var alertErrorMessage: String?
        var invalidAttempts = 0
        var isNotificationAuthorized = false

        var title: String
        var selectedDate: Date?
        var selectedTime: Date?

        init(reminder: Reminder?) {
            self.reminder = reminder
            self.title = reminder?.title ?? ""
            self.selectedDate = reminder?.date
            self.selectedTime = reminder?.time
        }
    }
}
