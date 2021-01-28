//
//  RemindersStore.swift
//  Memo (iOS)
//
//  Created by Titouan Van Belle on 28.01.21.
//

import Coil
import Combine
import Foundation

final class RemindersStore: ObservableObject {

    enum Status {
        case idle
        case loadingReminders
        case togglingReminder(Reminder)
        case deletingReminder(Int, Reminder)
    }

    @Published var status: Status = .idle
    @Published var reminders: [[Reminder]] = []
    @Published var alertErrorMessage: String?
    @Published var isSheetPresented = false
    @Published var selectedReminder: Reminder?

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
        case .deletingReminder(let index, let reminder):
            return Self.whenDeletingReminder(reminder: reminder, section: index, database: database, notifier: notifier)
        default:
            return Empty().eraseToAnyPublisher()
        }
    }
}

// MARK: State Machine

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        sorted { a, b in
            a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }
}

extension RemindersStore {
    func send(event: Event) {
        switch event {

        case .loadReminders:
            status = .loadingReminders

        case .onRemindersLoaded(let newReminders):
            reminders = Dictionary(grouping: newReminders) { reminder -> String in
                if let date = reminder.date {
                    return DateFormatter.dateWithoutTime.string(from: date)
                } else {
                    return ""
                }
            }.values.sorted(by: {
                ($0[0].date ?? .distantPast) < ($1[0].date ?? .distantPast)
            })

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

        case .deleteReminder(let sectionIndex, let reminder):
            status = .deletingReminder(sectionIndex, reminder)

        case .onReminderDeleted(let sectionIndex, let reminder):
            status = .idle

        case .onFailedToDeleteReminder(let error):
            alertErrorMessage = error.localizedDescription
            status = .idle

        case .selectReminder(let reminder):
            selectedReminder = reminder
            isSheetPresented = true

        case .dismissError:
            alertErrorMessage = nil
        }
    }

    func action(for event: Event) -> () -> Void {
        { self.send(event: event) }
    }
}

// MARK: Feedbacks

extension RemindersStore {

    static func whenLoadingReminders(database: CoreDatabaseProtocol) -> AnyPublisher<Event, Never> {
        database.fetchAndListen(request: Reminder.all)
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
        section: Int,
        database: CoreDatabaseProtocol,
        notifier: NotifierProtocol
    ) -> AnyPublisher<Event, Never> {
        Publishers.Zip(
            database.deleteReminder(reminder),
            notifier.cancelNotification(withIdentifier: "\(reminder.objectID)")
                .setFailureType(to: Error.self)
        )
        .map(\.0)
        .map { Event.onReminderDeleted(section, $0) }
        .catch { Just(Event.onFailedToDeleteReminder($0)) }
        .eraseToAnyPublisher()
    }
}


extension RemindersStore: ResolverProvider {}

