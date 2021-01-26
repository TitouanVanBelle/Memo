//
//  SetupAppForScreenshotTarget.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 26.01.21.
//

import Foundation
import Combine

final class SetupAppForScreenshotTarget: LaunchCommand {

    private let database = CoreDatabase()
    private var cancellables = Set<AnyCancellable>()

    var shouldExecuteOnlyOnce: Bool {
        true
    }

    let reminders = [
        ReminderData(
            title: "Water plants",
            date: .today,
            time: Date(hour: 09, minute: 00)
        ),
        ReminderData(
            title: "Call mom",
            date: .today,
            time: Date(hour: 10, minute: 00)
        ),
        ReminderData(
            title: "Answer Tom's email",
            date: .today,
            time: Date(hour: 17, minute: 00)
        ),
        ReminderData(
            title: "Exercise",
            date: .today,
            time: Date(hour: 18, minute: 30)
        )
    ]

    override func execute() {
        super.execute()
        
        reminders.publisher
            .flatMap {
                self.database.createReminder(data: $0)
            }
            .sink(
                receiveCompletion: { result in
                    if case .failure(let error) = result {
                        print("❗️Error: \(error.localizedDescription)")
                    } else {
                        print("🛠 Seeded \(self.reminders.count) reminders into database")
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
}
