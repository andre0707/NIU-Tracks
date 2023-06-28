//
//  TracksTable.swift
//  NIU-Tracks
//
//  Created by Andre Albach on 17.06.23.
//

import SwiftUI


/// A table view which shows all tracks stored on the database
struct TracksTable: View {
    
    /// A measurement formatter for the distance
    static private let measurementFormatter = MeasurementFormatter()
    
    /// A time formatter for the riding time
    static private let timeComponentFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        
        return formatter
    }()
    
    /// Reference to the view model
    @ObservedObject var scooterCoordinator: ScooterCoordinator
        
    /// The body
    var body: some View {
        Table(scooterCoordinator.tracks) {
            TableColumn("Date") { track in
                Text(verbatim: "\(track.startTime!.formatted(date: .numeric, time: .shortened))")
            }
            
            TableColumn("Driver") { track in
                Picker("", selection: Binding(get: {
                    track.driver
                }, set: {
                    guard track.driver != $0 else { return }
                    track.driver = $0
                    track.managedObjectContext?.save(with: .driverChanged)
                    scooterCoordinator.readTracksFromDatabase()
                }), content: {
                    ForEach(Driver.allCases, id: \.self) { driver in
                        Text(verbatim: driver.description)
                            .tag(driver)
                    }
                })
            }
            .width(ideal: 100)
            
            TableColumn("Distance") { track in
                Text(verbatim: TracksTable.measurementFormatter.string(from: track.distanceMeasurement))
            }
            .width(ideal: 80)
            
            TableColumn("Riding time [min:sec]") { track in
                Text(verbatim: "\(TracksTable.timeComponentFormatter.string(from: TimeInterval(track.ridingTime)) ??  "")")
            }
            .width(ideal: 80)
            
            TableColumn("Average speed") { track in
                Text(verbatim: TracksTable.measurementFormatter.string(from: track.averageSpeedMeasurement))
            }
            .width(ideal: 100)
            
            TableColumn("Power consumption") { track in
                Text(verbatim: "\(track.powerConsumption)%")
            }
            .width(ideal: 120)
            
//            TableColumn("Track Id") { track in
//                Text(verbatim: track.trackId ?? "-")
//            }
        }
    }
}


// MARK: - Previews

struct TracksTable_Previews: PreviewProvider {
    static var previews: some View {
        TracksTable(scooterCoordinator: ScooterCoordinator.preview)
            .frame(width: 800, height: 600)
    }
}
