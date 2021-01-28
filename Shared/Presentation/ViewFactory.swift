//
//  ViewFactory.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 24.01.21.
//

import Foundation
import SwiftUI

final class ViewFactory {

    let todayStore = TodayStore(Container.default)

    func makeTodayView() -> some View {
        TodayView(store: todayStore, viewFactory: self)
    }

    func makeReminderView(for reminder: Reminder?) -> some View {
        ReminderView(store: ReminderStore(Container.default, reminder: reminder))
    }

    func makeRemindersView() -> some View {
        RemindersView(store: RemindersStore(Container.default), viewFactory: self)
    }
}
