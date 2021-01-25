//
//  Reminder+CoreDataProperties.swift
//  Yoda (iOS)
//
//  Created by Titouan Van Belle on 07.01.21.
//
//

import Foundation
import CoreData

@objc(Reminder)
public class Reminder: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        NSFetchRequest<Reminder>(entityName: "Reminder")
    }

    @NSManaged public var title: String
    @NSManaged public var date: Date?
    @NSManaged public var timeInSeconds: Int32
    @NSManaged public var completedDate: Date?
    @NSManaged public var group: Group?

    var isCompleted: Bool {
        get { completedDate != nil }
        set { completedDate = newValue ? .today : nil }
    }

    var combinedDateAndTime: Date? {
        guard let date = date else {
            return nil
        }

        guard let time = time else {
            return date
        }

        var components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        components.hour = timeComponents.hour!
        components.minute = timeComponents.minute!

        return Calendar.current.date(from: components)
    }

    var time: Date? {
        get {
            guard timeInSeconds != -1 else {
                return nil
            }

            var components = DateComponents()
            components.hour = Int(timeInSeconds) / 3600
            components.minute = Int(timeInSeconds) % 3600 / 60

            return Calendar.current.date(from: components)!
        }
        set {
            guard let date = newValue else {
                timeInSeconds = -1
                return
            }

            let components = Calendar.current.dateComponents([.hour, .minute], from: date)

            timeInSeconds = Int32(components.hour! * 3600 + components.minute! * 60)
        }
    }
}

extension Reminder : Identifiable {

}
