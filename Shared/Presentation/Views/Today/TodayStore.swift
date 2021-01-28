//
//  TodaySummaryViewModel.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 04.01.21.
//

import Coil
import Combine
import Foundation

final class TodayStore: ObservableObject {

    enum Status {
        case idle
        case loadingReminders
        case togglingReminder(Reminder)
        case deletingReminder(Reminder)
    }

    enum SheetContentType {
        case reminder(Reminder?)
        case allReminders
    }

    @Published var status: Status = .idle
    @Published var reminders: [Reminder] = []
    @Published var alertErrorMessage: String?

    @Published var sheetContentType: SheetContentType = .allReminders
    @Published var isSheetPresented = false

    private var cancellables = Set<AnyCancellable>()

    // MARK: Dependencies

    @Injected var database: CoreDatabaseProtocol
    @Injected var soundPlayer: SoundsPlayerProtocol
    @Injected var notifier: NotifierProtocol

    let resolver: Resolver

    // MARK: Init
    init(_ resolver: Resolver) {
        self.resolver = resolver

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
        case .loadingReminders:
            return Self.whenLoadingReminders(database: database)
        case .togglingReminder(let reminder):
            return Self.whenTogglingReminder(reminder: reminder, database: database, soundPlayer: soundPlayer)
        case .deletingReminder(let reminder):
            return Self.whenDeletingReminder(reminder: reminder, database: database, notifier: notifier)
        default:
            return Empty().eraseToAnyPublisher()
        }
    }
}

// MARK: State Machine

extension TodayStore {
    func send(event: Event) {
        switch event {

        case .loadReminders:
            status = .loadingReminders

        case .onRemindersLoaded(let newReminders):
            reminders = newReminders
            status = .idle

        case .onFailedToLoadReminders(let error):
            alertErrorMessage = error.localizedDescription
            status = .idle

        case .toggleReminder(let reminder):
            status = .togglingReminder(reminder)

        case .onReminderToggled(_):
            status = .idle

        case .onFailedToToggleReminder:
            status = .idle

        case .deleteReminder(let reminder):
            status = .deletingReminder(reminder)

        case .onReminderDeleted(let reminder):
            let index = reminders.firstIndex(of: reminder)!
            reminders.remove(at: index)

        case .onFailedToDeleteReminder(let error):
            alertErrorMessage = error.localizedDescription

        case .selectReminder(let reminder):
            sheetContentType = .reminder(reminder)
            isSheetPresented = true

        case .createNewReminder:
            sheetContentType = .reminder(nil)
            isSheetPresented = true

        case .seeAllReminders:
            isSheetPresented = true
            sheetContentType = .allReminders

        case .dismissError:
            alertErrorMessage = nil
        }
    }

    func action(for event: Event) -> () -> Void {
        { self.send(event: event) }
    }
}

// MARK: Feedbacks

extension TodayStore {

    static func whenLoadingReminders(database: CoreDatabaseProtocol) -> AnyPublisher<Event, Never> {
        database.fetchAndListen(request: Reminder.todaysReminders)
            .map(Event.onRemindersLoaded)
            .catch { Just(Event.onFailedToLoadReminders($0)) }
            .eraseToAnyPublisher()
    }

    static func whenTogglingReminder(
        reminder: Reminder,
        database: CoreDatabaseProtocol,
        soundPlayer: SoundsPlayerProtocol
    ) -> AnyPublisher<Event, Never> {
        Publishers.Zip(
            database.toggleReminder(reminder),
            soundPlayer.play(reminder.isCompleted ? .reminderCompleted : .reminderUncompleted)
        )
        .map(\.0)
        .map(Event.onReminderToggled)
        .catch { Just(Event.onFailedToToggleReminder($0)) }
        .eraseToAnyPublisher()
    }

    static func whenDeletingReminder(
        reminder: Reminder,
        database: CoreDatabaseProtocol,
        notifier: NotifierProtocol
    ) -> AnyPublisher<Event, Never> {
        Publishers.Zip(
            database.deleteReminder(reminder),
            notifier.cancelNotification(withIdentifier: "\(reminder.objectID)")
                .setFailureType(to: Error.self)
        )
        .map(\.0)
        .map(Event.onReminderDeleted)
        .catch { Just(Event.onFailedToDeleteReminder($0)) }
        .eraseToAnyPublisher()
    }
}


extension TodayStore: ResolverProvider {}
