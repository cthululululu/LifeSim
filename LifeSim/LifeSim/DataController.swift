/**
    #DataController.swift
 
    Sets up and manages CoreData stack for the application. Provides
    shared instance of `PersistenceController` to allow for a single,
    consistent controller across the entire application. Initializes
    `NSPersistentContainer` to handle persistent stores.
 */

import CoreData

struct PersistenceController {
    
    // Creates shared instance of PersistenceController
    static let shared = PersistenceController()
    // Defines Core Data Container
    let container: NSPersistentContainer

    // Initializes Core Data stack. Allows option for in-memory storage
    init(inMemory: Bool = false) {
        
        // Refers to CoreData model in LifeSimpAppModel.xcdatamodeld
        container = NSPersistentContainer(name: "LifeSimAppModel")
        
        // If CoreData model should use in-memory storage
        if inMemory {
            // Disables Persistent Storage
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        // Loads Persistent Storage into CoreData container
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    // Provides in-memory Core Data stack in previews
    // Essential for all Views to be able to create a Preview
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        return result
    }()
}
