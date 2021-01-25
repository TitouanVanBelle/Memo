//
//  YodaApp.swift
//  Shared
//
//  Created by Titouan Van Belle on 04.01.21.
//

import SwiftUI

@main
struct YodaApp: App {

    let viewFactory = ViewFactory()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            AppView(viewFactory: viewFactory)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)

        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                try? PersistenceController.shared.container.viewContext.save()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        PersistenceController.shared.container.viewContext.persistentStoreCoordinator?.persistentStores.forEach({
            if let url = $0.url {
                print(url)
            }
        })

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        try? PersistenceController.shared.container.viewContext.save()
    }
}
