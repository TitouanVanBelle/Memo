//
//  PrintDatabasePath.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 26.01.21.
//

import Foundation

final class PrintDatabasePath: LaunchCommand {
    var shouldExecuteOnlyOnce: Bool {
        false
    }

    override func execute() {
        super.execute()

        PersistenceController.shared.container.viewContext.persistentStoreCoordinator?.persistentStores.forEach({
            if let url = $0.url {
                print("🛠 SQLite Database is located at: \(url.path)")
            }
        })
    }
}
