 //
//  CDPublisher.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 20.01.21.
//

import Coil
import Combine
import CoreData
import Foundation

enum CoreDataErrorReason: String {
    case reminderTitleEmpty = "Reminder title is empty"
    case dateInPast = "Date is in the past"
}

enum CoreDataError: Error, LocalizedError {
    case creationFailed(CoreDataErrorReason)
    case savingFailed(Error)
    case deletingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .creationFailed(let reason):
            return reason.rawValue
        case .savingFailed(let error):
            return error.localizedDescription
        case .deletingFailed(let error):
            return error.localizedDescription
        }
    }
}

protocol CoreDatabaseProtocol {
    func createReminder(data: ReminderData) -> AnyPublisher<Reminder, Error>
    func toggleReminder(_ reminder: Reminder) -> AnyPublisher<Reminder, Error>
    func deleteReminder(_ reminder: Reminder) -> AnyPublisher<Reminder, Error>
    func updateReminder(_ reminder: Reminder, with data: ReminderData) -> AnyPublisher<Reminder, Error>
    func fetch<Entity>(request: NSFetchRequest<Entity>) -> CoreDatabasePublisher<Entity>
}


final class CoreDatabase: CoreDatabaseProtocol {

    private var context: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }

    func createReminder(data: ReminderData) -> AnyPublisher<Reminder, Error> {
        Future { promise in
            guard !data.title.isEmpty else {
                promise(.failure(CoreDataError.creationFailed(.reminderTitleEmpty)))
                return
            }

            if let date = data.date {
                var actualDate = date
                if let time = data.time {
                    var components = Calendar.current.dateComponents([.day, .month, .year], from: actualDate)
                    let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
                    components.hour = timeComponents.hour!
                    components.minute = timeComponents.minute!

                    actualDate = Calendar.current.date(from: components)!
                }

                if actualDate.isInPast {
                    promise(.failure(CoreDataError.creationFailed(.dateInPast)))
                    return
                }
            }

            print("💾 Creating reminder with title \(data.title)")
            let reminder = Reminder(context: self.context)
            reminder.title = data.title
            reminder.date = data.date
            reminder.time = data.time

            do {
                try self.context.save()
                promise(.success(reminder))
            } catch {
                promise(.failure(CoreDataError.savingFailed(error)))
            }
        }.eraseToAnyPublisher()
    }

    func toggleReminder(_ reminder: Reminder) -> AnyPublisher<Reminder, Error> {
        Future { promise in
            print("💾 Toggling reminder with title \(reminder.title)")
            reminder.isCompleted = !reminder.isCompleted

            do {
                try self.context.save()
                promise(.success(reminder))
            } catch {
                promise(.failure(CoreDataError.savingFailed(error)))
            }
        }.eraseToAnyPublisher()
    }

    func deleteReminder(_ reminder: Reminder) -> AnyPublisher<Reminder, Error> {
        Future { promise in
            print("💾 Deleting reminder with title \(reminder.title)")
            self.context.delete(reminder)

            do {
                try self.context.save()
                promise(.success(reminder))
            } catch {
                promise(.failure(CoreDataError.deletingFailed(error)))
            }
        }.eraseToAnyPublisher()
    }

    func updateReminder(_ reminder: Reminder, with data: ReminderData) -> AnyPublisher<Reminder, Error> {
        Future { promise in
            guard !data.title.isEmpty else {
                promise(.failure(CoreDataError.creationFailed(.reminderTitleEmpty)))
                return
            }

            if let date = data.date {
                var actualDate = date
                if let time = data.time {
                    var components = Calendar.current.dateComponents([.day, .month, .year], from: actualDate)
                    let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
                    components.hour = timeComponents.hour!
                    components.minute = timeComponents.minute!

                    actualDate = Calendar.current.date(from: components)!
                }

                if actualDate.isBeforeToday {
                    promise(.failure(CoreDataError.creationFailed(.dateInPast)))
                    return
                }
            }

            print("💾 Updating reminder with title \(data.title)")

            reminder.title = data.title
            reminder.date = data.date
            reminder.time = data.time

            do {
                try self.context.save()
                promise(.success(reminder))
            } catch {
                promise(.failure(CoreDataError.savingFailed(error)))
            }
        }.eraseToAnyPublisher()
    }

    func fetch<Entity>(request: NSFetchRequest<Entity>) -> CoreDatabasePublisher<Entity> where Entity: NSManagedObject {
        CoreDatabasePublisher(request: request, context: context)
    }
}
