//
//  RemindApp.swift
//  Shared
//
//  Created by Titouan Van Belle on 04.01.21.
//

import SwiftUI

@main
struct MemoApp: App {

    let viewFactory = ViewFactory()

    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            AppView(viewFactory: viewFactory)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)

        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                try? PersistenceController.shared.container.viewContext.save()
            } else if phase == .active {
                if let lastFetchedDate = UserDefaults.standard.lastFetchedDate, lastFetchedDate.isBeforeToday {
                    UserDefaults.standard.shouldUpdateData = true
                }
            }
        }
    }
}
