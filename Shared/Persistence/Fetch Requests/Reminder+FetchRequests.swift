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
        NSPredicate(format: "date == %@ AND (completedDate == nil OR completedDate >= %@)", startOfToday, startOfToday)
    }()

    static let pastUncompletedRemindersPredicate: NSPredicate = {
        NSPredicate(format: "date < %@ AND (completedDate == nil OR completedDate >= %@)", startOfToday, startOfToday)
    }()

    static let remindersWithoutDatePredicate: NSPredicate = {
        NSPredicate(format: "date == nil AND (completedDate == nil OR completedDate >= %@)", startOfToday, startOfToday)
    }()

    // MARK: Fetch Requests

    private static var basicRequest: NSFetchRequest<Reminder> {
        let request = NSFetchRequest<Reminder>(entityName: "Reminder")
        request.sortDescriptors = [
            NSSortDescriptor(key: "completedDate", ascending: true),
            NSSortDescriptor(key: "title", ascending: true)
        ]
        return request
    }

    static let all: NSFetchRequest<Reminder> = {
        basicRequest
    }()

    static let todaysReminders: NSFetchRequest<Reminder> = {
        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            pastUncompletedRemindersPredicate,
            todaysReminderPredicate,
            remindersWithoutDatePredicate
        ])

        let request = basicRequest
        request.predicate = predicate

        return request
    }()
}
