//
//  UserDefault+UserSettings.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 10.01.21.
//

import Foundation

extension UserDefaults {
    @UserDefault(.allDayNotificationTime, defaultValue: Date(hour: 08, minute: 00, second: 00)!)
    static var allDayNotificationTime: Date

    @objc var lastFetchedDate: Date? {
        get { object(forKey: "lastFetchedDate") as? Date }
        set { set(newValue, forKey: "lastFetchedDate") }
    }

    @objc var shouldUpdateData: Bool {
        get { bool(forKey: "shouldUpdateData") }
        set { set(newValue, forKey: "shouldUpdateData") }
    }
}
