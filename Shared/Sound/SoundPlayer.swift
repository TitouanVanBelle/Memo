//
//  SoundPlayer.swift
//  Yoda (iOS)
//
//  Created by Titouan Van Belle on 21.01.21.
//

import AVFoundation
import Foundation
import Combine

enum Sound {
    case reminderCreated
    case reminderCompleted
    case reminderUncompleted
    case validationError

    var filename: String {
        switch self {
        case .reminderCreated:
            return "ReminderCreated"
        case .reminderCompleted:
            return "ReminderCompleted"
        case .reminderUncompleted:
            return "ReminderUncompleted"
        case .validationError:
            return "ValidationError"
        }
    }

    var ext: String {
        "wav"
    }
}

enum SoundsPlayerError: Error, LocalizedError {
    case fileNotFound
    case cannotCreatePlayer
}

protocol SoundsPlayerProtocol {
    func play(_ sound: Sound) -> AnyPublisher<Void, Error>
}

final class SoundsPlayer: SoundsPlayerProtocol {

    var player: AVAudioPlayer?

    func play(_ sound: Sound) -> AnyPublisher<Void, Error> {
        Future { promise in
            guard let url = Bundle.main.url(forResource: sound.filename, withExtension: sound.ext) else {
                promise(.failure(SoundsPlayerError.fileNotFound))
                return
            }

            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)

                self.player = try AVAudioPlayer(contentsOf: url)

                guard let player = self.player else {
                    promise(.failure(SoundsPlayerError.cannotCreatePlayer))
                    return
                }

                player.play()

                promise(.success(()))
            } catch let error {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}

