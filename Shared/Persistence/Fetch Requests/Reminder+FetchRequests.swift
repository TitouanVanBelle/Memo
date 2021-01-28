//
//  Reminder.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 12.01.21.
//

import CoreData

extension Reminder {

    // MARK: Private

    static var startOfToday: NSDate {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let today = calendar.startOfDay(for: Date())
        return today as NSDate
    }

    // MARK: Predicates

    static let todaysReminderPredicate: NSPredicate = {
        .init(format: "date == %@ AND (completedDate == nil OR completedDate >= %@)", startOfToday, startOfToday)
    }()

    static let pastUncompletedRemindersPredicate: NSPredicate = {
        .init(format: "date < %@ AND (completedDate == nil OR completedDate >= %@)", startOfToday, startOfToday)
    }()

    static let remindersWithoutDatePredicate: NSPredicate = {
        .init(format: "date == nil AND (completedDate == nil OR completedDate >= %@)", startOfToday, startOfToday)
    }()

    // MARK: Fetch Requests

    private static var basicRequest: NSFetchRequest<Reminder> {
        let request = NSFetchRequest<Reminder>(entityName: "Reminder")
        request.sortDescriptors = [
            .init(keyPath: \Reminder.completedDate, ascending: true),
            .init(keyPath: \Reminder.date, ascending: true),
            .init(keyPath: \Reminder.timeInSeconds, ascending: true)
        ]
        return request
    }

    static let all: NSFetchRequest<Reminder> = {
        basicRequest
    }()

    static let todaysReminders: NSFetchRequest<Reminder> = {
        let request = basicRequest
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            pastUncompletedRemindersPredicate,
            todaysReminderPredicate,
            remindersWithoutDatePredicate
        ])

        return request
    }()
}
