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
}
