//
//  CoreDataStack.swift
//  NIU-Tracks
//
//  Created by Andre Albach on 17.06.23.
//


import CoreData
import os

/// A logger to log errors
fileprivate let logger = Logger(subsystem: "de.aaindustries", category: "CoreDataStack")


/// The core data stack
final class CoreDataStack {
    
    // MARK: - Identifier and Names
    
    /// The name of the container. This should be the name of the `.xcdatamodel` file which describes the enteties etc.
    static private let containerName: String = "NIU_Tracks"
    
    /// The file name of the underlaying store file for the local configuration
    static private var fileNameLocalStore: String { "\(CoreDataStack.containerName).sqlite" }
    
    
    // MARK: - Variables
    
    /// A shared instance to use for preview data
    static let preview = CoreDataStack(isInMemoryStore: true)
    
    /// A shared instance to use
    static let shared = CoreDataStack()
    
    /// The underlaying persistent container
    let container: NSPersistentContainer
    
    /// Easier access to the view context which is used for every Main-Thread reladed updates
    var viewContext: NSManagedObjectContext { container.viewContext }
    
    
    private init(isInMemoryStore: Bool = false) {
        /// Create the container
        self.container = NSPersistentContainer(name: CoreDataStack.containerName)
        
        let urlPath = container.persistentStoreDescriptions.first?.url?.path ?? "-"
        logger.debug("Database stored at app container: \(urlPath, privacy: .public)")
        
        /// If multiple store descriptions are needed, this is where they should be added.
        /// ---
        
        
        /// To enable spotlight indexing, we need to set the NSCoreDataCoreSpotlightExporter key to all descriptions
        /// Also enable history tracking and remote notifications
        container.persistentStoreDescriptions.forEach {
            $0.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            
            /// In case spotlight is used, set the spotlight delegate subclass here. Important is to set `NSPersistentHistoryTrackingKey` before setting the spotlight delegate.
            ///$0.setOption(NSCoreDataCoreSpotlightDelegate(forStoreWith: $0, coordinator: container.persistentStoreCoordinator), forKey: NSCoreDataCoreSpotlightExporter)
                        
            if isInMemoryStore {
                /// There is a special url if the store should only live in memory. This will also override the above set app group url
                $0.url = URL(fileURLWithPath: "/dev/null")
            }
        }
        
        /// Load the persistent store
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        /// Some viewContext initialisations
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.automaticallyMergesChangesFromParent = true
        /// Make sure the data read from the persistent store stays in `viewContext`.
        /// Also see: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/MO_Lifecycle.html#//apple_ref/doc/uid/TP40001075-CH31-SW1
        container.viewContext.retainsRegisteredObjects = true
    }
    
    
    /// This function will delete all persistent history
    func deletePersistentHistory() {
        let purgeHistoryRequest = NSPersistentHistoryChangeRequest.deleteHistory(before: Date.now)

        do {
            try container.newBackgroundContext().execute(purgeHistoryRequest)
            logger.info("Successfully deleted persistent history.")
        } catch {
            logger.error("Error deleting persistent history. Error: \(error, privacy: .public)")
        }
    }
}
