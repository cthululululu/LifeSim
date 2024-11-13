/**
    #LifeSimApp.swift
    
    Main entry point of application. Initializes HomeView as the main view. Sets up
    the CoreData context in the environment. Allows views to access the Core
    Data stack by a single, consistent controller across the entire application.
 */

import SwiftUI
import CoreData

@main // Defines Main Entry Point
struct LifeSimApp: App {
    
    // Ensures App uses consistent controller to manage CoreData
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                // Provides managed object context to HomeView
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
