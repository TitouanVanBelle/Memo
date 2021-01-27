//
//  AppDelegate.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 26.01.21.
//

import Foundation
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        let commands = launchCommands(for: launchOptions)
        LaunchCommandExecuter.execute(commands)

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        try? PersistenceController.shared.container.viewContext.save()
    }
}

fileprivate extension AppDelegate {
    func launchCommands(for: [UIApplication.LaunchOptionsKey : Any]? = nil) -> [LaunchCommand] {
        var commands = [LaunchCommand]()

        #if DEBUG
        commands += [
            PrintDatabasePath()
        ]
        #endif

        if ProcessInfo.processInfo.arguments.contains("-setupAppForScreenshotTarget") {
            commands += [SetupAppForScreenshotTarget()]
        }

        return commands
    }
}
