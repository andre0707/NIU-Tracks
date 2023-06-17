//
//  NSManagedObjectContext.swift
//  NIU-Tracks
//
//  Created by Andre Albach on 17.06.23.
//

import CoreData
import os

/// A logger to log errors
fileprivate let logger = Logger(subsystem: "de.aaindustries", category: "CoreDataStack")


extension NSManagedObjectContext {
    
    /// A custom save method to provide a contextual context when saving changes
    /// - Parameter contextualInfo: The contextual infos when saving
    @discardableResult
    func save(with contextualInfo: ContextSaveContextualInfo) -> Bool {
        guard hasChanges else { return true }
        
        do {
            try save()
            return true
        } catch {
            handleSavingError(error, contextualInfo: contextualInfo)
            return false
        }
    }
    
    /// This function will handle the error we got while saving
    /// - Parameters:
    ///   - error: the error from the catch block
    ///   - contextualInfo: the context information by which save task the error occurred
    private func handleSavingError(_ error: Error, contextualInfo: ContextSaveContextualInfo) {
        logger.error("Failed to save the context when \(contextualInfo.rawValue, privacy: .public).\nError: \(error.localizedDescription, privacy: .public)")
    }
}
