//
//  NewReminderStore.swift
//  Remind
//
//  Created by Titouan Van Belle on 19.01.21.
//

import Coil
import Combine
import CoreGraphics
import Foundation

final class ReminderStore: ObservableObject {

    enum Status {
        case idle
        case checkingNotificationAuthorization
        case requestingAuthorization
        case creatingReminder(ReminderData)
        case updatingReminder(Reminder, ReminderData)
    }

    enum BottomViewContent {
        case datePicker
        case timePicker
    }

    let resolver: Resolver
    let reminder: Reminder?

    @Published var status: Status = .idle

    @Published var title: String
    @Published var selectedDate: Date?
    @Published var selectedTime: Date?

    @Published var focusedTag = 0
    @Published var bottomViewContent: BottomViewContent?
    @Published var keyboardHeight: Double = 301
    @Published var shouldShowEmptyTitleErrorMessage = false
    @Published var shouldShowDateInPastErrorMessage = false
    @Published var shouldDismiss = false
    @Published var alertErrorMessage: String?
    @Published var invalidAttempts = 0
    @Published var isNotificationAuthorized = false

    private var cancellables = Set<AnyCancellable>()

    // MARK: Dependencies

    @Injected var database: CoreDatabaseProtocol
    @Injected var soundPlayer: SoundsPlayerProtocol
    @Injected var notifier: NotifierProtocol

    // MARK: Init

    init(_ resolver: Resolver, reminder: Reminder?) {
        self.resolver = resolver
        self.reminder = reminder
        self.title = reminder?.title ?? ""
        self.selectedDate = reminder?.date
        self.selectedTime = reminder?.time

        setupBindings()
    }
    
    func setupBindings() {
        $status
            .flatMap { [weak self] status -> AnyPublisher<Event, Never> in
                guard let self = self else {
                    return Empty().eraseToAnyPublisher()
                }

                return self.feedback(for: status)
            }
            .sink { [weak self] event in
                self?.send(event: event)
            }
            .store(in: &cancellables)
    }

    func feedback(for status: Status) -> AnyPublisher<Event, Never> {
        switch status {

        case .checkingNotificationAuthorization:
            return Self.whenCheckingNotificationAuthorization(notifier: notifier)
        case .requestingAuthorization:
            return Self.whenAuthorizingNotification(notifier: notifier)
        case .creatingReminder(let data):
            return Self.whenCreatingReminder(data: data, database: database, notifier: notifier, soundPlayer: soundPlayer)
        case .updatingReminder(let reminder, let data):
            return Self.whenUpdatingReminder(reminder: reminder, data: data, database: database, notifier: notifier, soundPlayer: soundPlayer)

        default:
            return Empty().eraseToAnyPublisher()
        }
    }
}


// MARK: State Machine

extension ReminderStore {
    func send(event: Event) {
        switch event {

        case .checkNotificationAuthorization:
            status = .checkingNotificationAuthorization

        case .onNotificationAuthorizationChecked(let isAuthorized):
            isNotificationAuthorized = isAuthorized
            if isAuthorized {
                status = .idle
            } else {
                status = .requestingAuthorization
            }

        case .onNotificationAuthorized:
            isNotificationAuthorized = true
            status = .idle

        case .onNotificationDeclined(_):
            isNotificationAuthorized = false
            status = .idle


        // MARK: Create Reminder

        case .createReminder:

            let data = ReminderData(
                title: title,
                date: selectedDate,
                time: selectedTime
            )

            if data.title.isEmpty {
                shouldShowEmptyTitleErrorMessage = true
            } else {
                shouldShowEmptyTitleErrorMessage = false
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
                    invalidAttempts += 1
                    shouldShowDateInPastErrorMessage = true
                } else {
                    shouldShowDateInPastErrorMessage = false
                }
            }

            if shouldShowDateInPastErrorMessage || shouldShowEmptyTitleErrorMessage {
                return
            }

            status = .creatingReminder(data)

        case .onReminderCreated:
                shouldDismiss = true
                status = .idle

        case .onFailedToCreateReminder(let error):
            alertErrorMessage = error.localizedDescription
            status = .idle

        // MARK: Update Reminder

        case .updateReminder:
            let data = ReminderData(
                title: title,
                date: selectedDate,
                time: selectedTime
            )

            if data.title.isEmpty {
                shouldShowEmptyTitleErrorMessage = true
            } else {
                shouldShowEmptyTitleErrorMessage = false
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
                    invalidAttempts += 1
                    shouldShowDateInPastErrorMessage = true
                } else {
                    shouldShowDateInPastErrorMessage = false
                }
            }

            if shouldShowDateInPastErrorMessage || shouldShowEmptyTitleErrorMessage {
                return
            }

            status = .updatingReminder(reminder!, data)

        case .onReminderUpdated:
            shouldDismiss = true
            status = .idle

        case .onFailedToUpdateReminder(let error):
            switch error as! CoreDataError {
            case .creationFailed(let reason):
                switch reason {
                case .reminderTitleEmpty:
                    shouldShowEmptyTitleErrorMessage = true
                case .dateInPast:
                    invalidAttempts += 1
                    shouldShowDateInPastErrorMessage = true
                }

            case .savingFailed(let error):
                alertErrorMessage = error.localizedDescription

            case .deletingFailed(let error):
                alertErrorMessage = error.localizedDescription
            }
            status = .idle

        case .dismissError:
            alertErrorMessage = nil

        case .selectDate(let date):
            selectedDate = date
            if date == nil {
                selectedTime = nil
            }

        case .showDatePicker:
            bottomViewContent = .datePicker
            focusedTag = -1

        case .showTimePicker:
            bottomViewContent = .timePicker
            focusedTag = -1

        case .clearBottomView:
            bottomViewContent = nil
        }
    }

    func action(for event: Event) -> () -> Void {
        { self.send(event: event) }
    }
}

// MARK: Feedbacks

extension ReminderStore {

    static func whenCheckingNotificationAuthorization(notifier: NotifierProtocol) -> AnyPublisher<Event, Never> {
        notifier.isNotificationAuthorized()
            .receive(on: DispatchQueue.main)
            .map(Event.onNotificationAuthorizationChecked)
            .eraseToAnyPublisher()
    }

    static func whenAuthorizingNotification(notifier: NotifierProtocol) -> AnyPublisher<Event, Never> {
        notifier.requestAuthorization()
            .receive(on: DispatchQueue.main)
            .map { Event.onNotificationAuthorized }
            .catch { Just(Event.onNotificationDeclined($0)) }
            .eraseToAnyPublisher()
    }

    static func whenCreatingReminder(
        data: ReminderData,
        database: CoreDatabaseProtocol,
        notifier: NotifierProtocol,
        soundPlayer: SoundsPlayerProtocol
    ) -> AnyPublisher<Event, Never> {
        Publishers.Zip(
            database.createReminder(data: data)
                .flatMap { reminder -> AnyPublisher<Void, Error> in
                    guard let date = reminder.combinedDateAndTime else {
                        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                    }

                    return notifier.scheduleNotification(withIdentifier: "\(reminder.objectID)", title: "Reminder", body: reminder.title, on: date, frequency: .once)
                },
            soundPlayer.play(.reminderCreated)
        )
        .receive(on: DispatchQueue.main)
        .map { _ in Event.onReminderCreated }
        .catch { Just(Event.onFailedToCreateReminder($0)) }
        .eraseToAnyPublisher()
    }

    static func whenUpdatingReminder(
        reminder: Reminder,
        data: ReminderData,
        database: CoreDatabaseProtocol,
        notifier: NotifierProtocol,
        soundPlayer: SoundsPlayerProtocol
    ) -> AnyPublisher<Event, Never> {
        Publishers.Zip3(
            database.updateReminder(reminder, with: data),
            notifier.cancelNotification(withIdentifier: "\(reminder.objectID)")
                .setFailureType(to: Error.self),
            soundPlayer.play(.reminderCreated)
        )
        .flatMap { zipped -> AnyPublisher<Void, Error> in
            guard let date = reminder.combinedDateAndTime else {
                return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
            }

            return notifier.scheduleNotification(withIdentifier: "\(reminder.objectID)", title: "Reminder", body: reminder.title, on: date, frequency: .once)
        }
        .receive(on: DispatchQueue.main)
        .map { _ in Event.onReminderUpdated }
        .catch { Just(Event.onFailedToUpdateReminder($0)) }
        .eraseToAnyPublisher()
    }
}

// MARK: View Model

extension ReminderStore {
    var bottomViewHeight: CGFloat {
        switch bottomViewContent {
        case .datePicker: return 330
        case .timePicker: return CGFloat(keyboardHeight)
        case nil: return 0
        }
    }

    var formattedSelectedDate: String {
        guard let selectedDate = selectedDate else {
            return ""
        }

        return DateFormatter.shortMonthAndDay.string(from: selectedDate)
    }

    var formattedSelectedTime: String {
        guard let selectedTime = selectedTime else {
            return ""
        }

        return DateFormatter.timeWithMeridian.string(from: selectedTime)
    }
}

extension ReminderStore: ResolverProvider {}
