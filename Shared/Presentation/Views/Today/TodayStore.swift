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
        case listeningToDateUpdate
        case listeningToReminderUpdates
        case fetchingReminders
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
        case .listeningToDateUpdate:
            return Self.whenListeningToDateUpdate(database: database)
        case .listeningToReminderUpdates:
            return Self.whenListeningToReminderUpdates(database: database)
        case .fetchingReminders:
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
        case .listenToDateUpdate:
            status = .listeningToDateUpdate

        case .onDateUpdateOrderReceived:
            UserDefaults.standard.shouldUpdateData = false
            status = .fetchingReminders

        case .fetchRemindersAndSubscribeToChange:
            status = .listeningToReminderUpdates

        case .fetchReminders:
            status = .fetchingReminders

        case .onRemindersFetched(let newReminders):
            UserDefaults.standard.lastFetchedDate = .today
            reminders = newReminders
            status = .idle

        case .onFailedToFetchReminders(let error):
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

        case .onReminderDeleted(let _):
            status = .idle

        case .onFailedToDeleteReminder(let error):
            alertErrorMessage = error.localizedDescription
            status = .idle

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

    static func whenListeningToDateUpdate(database: CoreDatabaseProtocol) -> AnyPublisher<Event, Never> {
        UserDefaults.standard
            .publisher(for: \.shouldUpdateData)
            .filter { $0 }
            .map { _ in Event.onDateUpdateOrderReceived }
            .eraseToAnyPublisher()
    }
    
    static func whenListeningToReminderUpdates(database: CoreDatabaseProtocol) -> AnyPublisher<Event, Never> {
        database.fetchAndListen(request: Reminder.todaysReminders)
            .map(Event.onRemindersFetched)
            .catch { Just(Event.onFailedToFetchReminders($0)) }
            .eraseToAnyPublisher()
    }

    static func whenLoadingReminders(database: CoreDatabaseProtocol) -> AnyPublisher<Event, Never> {
        database.fetch(request: Reminder.todaysReminders)
            .map(Event.onRemindersFetched)
            .catch { Just(Event.onFailedToFetchReminders($0)) }
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
