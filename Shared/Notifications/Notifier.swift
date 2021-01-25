//
//  Notifier.swift
//  Yoda (iOS)
//
//  Created by Titouan Van Belle on 07.01.21.
//

import Combine
import Foundation
import UserNotifications

protocol NotifierProtocol {
    func isNotificationAuthorized() -> AnyPublisher<Bool, Never>
    func requestAuthorization() -> AnyPublisher<Void, Error>
    func scheduleNotification(withIdentifier: String, title: String, body: String, on date: Date, frequency: NotificationFrequency) -> AnyPublisher<Void, Error>
    func cancelNotification(withIdentifier: String) -> AnyPublisher<Void, Never>
}

enum NotificationFrequency {
    case once
    case daily
    case weekly
    case monthly
    case yearly
}

enum NotifierError: Error {
    case unauthorized
}

final class Notifier: NotifierProtocol {

    static let shared = Notifier()

    private let notifierDelegate = NotifierDelegate()

    init() {
        UNUserNotificationCenter.current().delegate = notifierDelegate
    }

    func isNotificationAuthorized() -> AnyPublisher<Bool, Never> {
        Future { promise in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized || settings.authorizationStatus == .ephemeral {
                    promise(.success(true))
                } else {
                    promise(.success(false))
                }
            }
        }.eraseToAnyPublisher()
    }

    func requestAuthorization() -> AnyPublisher<Void, Error> {
        Future { promise in
            print("📢 Requesting authorization for notifications")
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    promise(.success(()))
                } else if let error = error {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }


    func scheduleNotification(withIdentifier identifier: String, title: String, body: String, on date: Date, frequency: NotificationFrequency) -> AnyPublisher<Void, Error> {
        Future { promise in
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Notification.caf"))

            let trigger = self.notificationTrigger(for: frequency, date: date)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            print("📢 Scheduling notification at \(date)")

            UNUserNotificationCenter.current().add(request)

            promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func cancelNotification(withIdentifier identifier: String) -> AnyPublisher<Void, Never> {
        Future { promise in

            print("🔔 Cancelling notification with \(identifier)")

            UNUserNotificationCenter.current()
                .removeDeliveredNotifications(withIdentifiers: [identifier])
            UNUserNotificationCenter.current()
                .removePendingNotificationRequests(withIdentifiers: [identifier])

            promise(.success(()))
        }.eraseToAnyPublisher()
    }
}

fileprivate extension Notifier {

    func notificationTrigger(for frequency: NotificationFrequency, date: Date) -> UNNotificationTrigger {
        let calendarComponents: (NotificationFrequency) -> Set<Calendar.Component> = { frequency in
            switch frequency {
            case .once: return [.year, .day, .month, .hour, .minute]
            case .daily: return [.hour, .minute]
            case .weekly: return [.weekday, .hour, .minute]
            case .monthly: return [.day, .hour, .minute]
            case .yearly: return [.day, .month, .hour, .minute]
            }
        }

        let dateComponents = Calendar.current.dateComponents(calendarComponents(frequency), from: date)
        return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    }
}

final class NotifierDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.banner)
    }
}
