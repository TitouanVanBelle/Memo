//
//  LaunchCommand.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 26.01.21.
//

import Foundation

class LaunchCommand {
    var shouldOnlyExecuteOnce = false

    private var userDefaultsKey: String {
        "LaunchCommand.\(String(describing: type(of: self)))"
    }

    public private(set) var executed: Bool {
        get { UserDefaults.standard.bool(forKey: userDefaultsKey) }
        set { UserDefaults.standard.set(newValue, forKey: userDefaultsKey) }
    }

    func execute() {
        executed = true
    }
}
