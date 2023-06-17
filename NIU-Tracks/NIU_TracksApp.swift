//
//  NIU_TracksApp.swift
//  NIU-Tracks
//
//  Created by Andre Albach on 17.06.23.
//

import SwiftUI

@main
struct NIU_TracksApp: App {
    
    /// Reference to the core data stack.
    let coreDataStack = CoreDataStack.shared
    
    /// Reference to the view model which drives the view
    @StateObject private var scooterCoordinator = ScooterCoordinator()
    
    /// The body
    var body: some Scene {
        
        // Using `Window` instead of `WindowGroup` here will ensure that no additional window can be opened.
        Window("NIU Tracks", id: "NIU-Tracks") {
            MainView(scooterCoordinator: scooterCoordinator)
                .environment(\.managedObjectContext, coreDataStack.viewContext)
        }
        .commands {
            CommandGroup(replacing: .help, addition: {
                Link("Help on GitHub", destination: URL(string: "https://github.com/andre0707/NIU-Tracks")!)
            })
            
            
            CommandGroup(before: .saveItem, addition: {
                Button("Login") {
                    scooterCoordinator.presentedSheet = .login
                }
                Button("Vehicle picker") {
                    scooterCoordinator.presentedSheet = .vehiclePicker
                }
                
                Divider()
                
                Button("Filter") {
                    scooterCoordinator.presentFilter = true
                }
                .keyboardShortcut("F", modifiers: .command)
                
                Divider()
                
                Button("Re-load all tracks from API") {
                    Task {
                        await scooterCoordinator.readFromAPI(readAll: true)
                        scooterCoordinator.readTracksFromDatabase()
                    }
                }
                .keyboardShortcut("R", modifiers: .command)
                Button("Load tracks from API") {
                    Task {
                        await scooterCoordinator.readFromAPI(readAll: false)
                        scooterCoordinator.readTracksFromDatabase()
                    }
                }
                .keyboardShortcut("L", modifiers: .command)
                
                Divider()
            })
        }
    }
}
