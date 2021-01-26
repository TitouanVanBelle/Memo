//
//  LaunchCommandExecuter.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 26.01.21.
//

import Foundation

final class LaunchCommandExecuter {

    // MARK: Public Method

    static func execute(_ commands: [LaunchCommand]) {
        commands.forEach { $0.execute() }
    }
}
