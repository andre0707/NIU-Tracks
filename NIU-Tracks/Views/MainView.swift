//
//  MainView.swift
//  NIU-Tracks
//
//  Created by Andre Albach on 17.06.23.
//

import SwiftUI
import CoreData

/// The main view of the app
struct MainView: View {
    
    /// Reference to the view model which drives the view
    @ObservedObject var scooterCoordinator: ScooterCoordinator
    
    /// A list of all the states the app can be in
    enum AppStates: Int, CaseIterable, Identifiable {
        case map
        case table
        
        var id: AppStates { self }
        
        var description: String {
            switch self {
            case .map: return "Map"
            case .table: return "Table"
            }
        }
    }
    /// The current app state. Saved in user defaults
    @AppStorage("lastAppState") private var appState: AppStates = .map
    
    /// The body
    var body: some View {
        
        // MARK: - View
        
        mainView
            .frame(minWidth: 1300, minHeight: 800)
        
        
        // MARK: - Toolbar
        
            .toolbar {
                ToolbarItemGroup {
                    
                    Text("Filtered to \(scooterCoordinator.tracksCount) tracks with \(scooterCoordinator.totalTrackDistance) total")
                        .font(.title2)
                    
                    HStack {
                        
                        /// Present login sheet
                        Button(action: {
                            scooterCoordinator.presentedSheet = .login
                        }, label: {
                            Label("Login", systemImage: "rectangle.and.pencil.and.ellipsis")
                                .foregroundColor(.orange)
                                .help("Open login sheet")
                        })
                        
                        /// Present vehicle picker sheet
                        Button(action: {
                            scooterCoordinator.presentedSheet = .vehiclePicker
                        }, label: {
                            Label("Vehicle picker", systemImage: "scooter")
                                .foregroundColor(.orange)
                                .help("Vehicle picker")
                        })
                        
                        Divider()
                    }
                    
                    HStack {
                        
                        /// Pick main menu
                        Picker("Mode", selection: $appState) {
                            ForEach(AppStates.allCases) { appState in
                                Text(verbatim: appState.description)
                                    .tag(appState)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Divider()
                        
                    }
                    
                    HStack {
                        
                        /// Show filter
                        Button(action: {
                            scooterCoordinator.presentFilter = true
                        }, label: {
                            Label("Filter", systemImage: "slider.horizontal.3")
                                .foregroundColor(.orange)
                                .help("Filter")
                        })
                        .popover(isPresented: $scooterCoordinator.presentFilter,
                                 attachmentAnchor: .point(.bottom),
                                 arrowEdge: .top) {
                            
                            FilterView(filterViewModel: scooterCoordinator.filterViewModel)
                                .padding()
                        }
                     
                        Divider()
                        
                    }
                    
//                    /// Re-Download all tracks from the API
//                    Button(action: {
//                        Task {
//                            await scooterCoordinator.readFromAPI(readAll: true)
//                            scooterCoordinator.readTracksFromDatabase()
//                        }
//                    }, label: {
//                        Label("Re-load all tracks from API", systemImage: "square.and.arrow.down.on.square")
//                            .foregroundColor(scooterCoordinator.isReadingDataFromAPI ? .gray : .orange)
//                            .help("Re-load all tracks from API")
//                    })
//                    .disabled(scooterCoordinator.isReadingDataFromAPI)
                    
                    /// Download last tracks from the API
                    Button(action: {
                        Task {
                            await scooterCoordinator.readFromAPI(readAll: false)
                            scooterCoordinator.readTracksFromDatabase()
                        }
                    }, label: {
                        Label("Load tracks from API", systemImage: "square.and.arrow.down")
                            .foregroundColor(scooterCoordinator.isReadingDataFromAPI ? .gray : .orange)
                            .help("Load tracks from API")
                    })
                    .disabled(scooterCoordinator.isReadingDataFromAPI)
                }
            }
        
        
        // MARK: - Sheet
        
            .sheet(item: $scooterCoordinator.presentedSheet, onDismiss: {
                scooterCoordinator.readTracksFromDatabase()
                
            }, content: { sheetValue in
                switch sheetValue {
                case .login:
                    LoginView(loginViewModel: scooterCoordinator.loginViewModel)
                        .frame(minWidth: 600, idealWidth: 600, maxWidth: 600, minHeight: 300, idealHeight: 350, maxHeight: 600, alignment: .center)
                    
                case .vehiclePicker:
                    VehiclePickerView()
                        .frame(minWidth: 600, idealWidth: 600, maxWidth: 600, minHeight: 300, idealHeight: 300, maxHeight: 400, alignment: .center)
                }
            })
        
        // MARK: - Alert
        
            .alert(scooterCoordinator.alertMessage, isPresented: $scooterCoordinator.presentMessageAlert, actions: {
                Button("OK") {
                    scooterCoordinator.presentMessageAlert = false
                }
            })
            
    }
    
    @ViewBuilder
    private var mainView: some View {
        switch appState {
        case .map:
            MapViewRepresentable(scooterCoordinator: scooterCoordinator)
            
        case .table:
            TracksTable(scooterCoordinator: scooterCoordinator)
        }
    }
}


// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(scooterCoordinator: ScooterCoordinator.preview)
            .environment(\.managedObjectContext, CoreDataStack.preview.viewContext)
    }
}
