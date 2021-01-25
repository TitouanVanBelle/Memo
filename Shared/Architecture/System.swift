//
//  System.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 25.01.21.
//

import Foundation
import Combine

extension Publishers {

    static func system<State, Event, Scheduler: Combine.Scheduler>(
        initial: State,
        reduce: @escaping (inout State, Event) -> Void,
        scheduler: Scheduler,
        feedbacks: [Feedback<State, Event>]
    ) -> AnyPublisher<State, Never> {

        let state = CurrentValueSubject<State, Never>(initial)

        let events = feedbacks.map { $0.run(state.eraseToAnyPublisher()) }

        return Deferred {
            Publishers.MergeMany(events)
                .receive(on: scheduler)
                .scan(initial, { (state, event) -> State in
                    var inoutState = state
                    reduce(&inoutState, event)
                    return inoutState
                })
                .handleEvents(receiveOutput: state.send)
                .receive(on: scheduler)
                .prepend(initial)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
