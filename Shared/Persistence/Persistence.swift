//
//  Persistence.swift
//  Shared
//
//  Created by Titouan Van Belle on 04.01.21.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

//    static var preview: PersistenceController = {
//        let result = PersistenceController(inMemory: true)
//        let viewContext = result.container.viewContext
//        let titles = ["Take pills", "Do laundry", "Go grocery shopping", "Call mum"]
//        for i in 0..<3 {
//            let reminder = Reminder(context: viewContext)
//            reminder.title = "Hi"
//            reminder.date = Date()
//            reminder.time = Date()
//            reminder.completed = true
//        }
//        do {
//            try viewContext.save()
//        } catch {
//            // Replace this implementation with code to handle the error appropriately.
//            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
//        return result
//    }()

    init(inMemory: Bool = false) {

        container = NSPersistentCloudKitContainer(name: "Yoda")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
