//
//  Group.swift
//  Yoda
//
//  Created by Titouan Van Belle on 19.01.21.
//

import Foundation
import CoreData

@objc(Group)
public class Group: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Group> {
        NSFetchRequest<Group>(entityName: "Group")
    }

    @NSManaged public var title: String
    @NSManaged public var reminders: NSSet?
}

extension Group {

    @objc(addRemindersObject:)
    @NSManaged public func addToReminders(_ value: Reminder)

    @objc(removeRemindersObject:)
    @NSManaged public func removeFromReminders(_ value: Reminder)

    @objc(addReminders:)
    @NSManaged public func addToReminders(_ values: NSSet)

    @objc(removeReminders:)
    @NSManaged public func removeFromReminders(_ values: NSSet)

}

extension Group : Identifiable {

}
