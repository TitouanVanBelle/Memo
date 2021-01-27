//
//  LaunchCommand.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 26.01.21.
//

import Foundation

class LaunchCommand {
    var shouldOnlyExecuteOnce = false

    private var commandName: String {
        String(describing: type(of: self))
    }

    private var userDefaultsKey: String {
        "LaunchCommand.\(commandName)"
    }

    public private(set) var executed: Bool {
        get { UserDefaults.standard.bool(forKey: userDefaultsKey) }
        set { UserDefaults.standard.set(newValue, forKey: userDefaultsKey) }
    }

    func execute() {
        print("🛠 Executing launch command \(commandName)")
        executed = true
    }
}
