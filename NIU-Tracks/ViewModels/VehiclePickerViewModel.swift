//
//  VehiclePickerViewModel.swift
//  NIU-Tracks
//
//  Created by Andre Albach on 17.06.23.
//

import Foundation
import NiuAPI
import os

/// A logger to log errors
fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier, category: "VehiclePickerViewModel")

/// The view model which drives the vehicle picker view
@MainActor
final class VehiclePickerViewModel: ObservableObject {
    
    /// The list of vehicles the user can chose from
    @Published private(set) var vehicles: [Vehicle] = []
    
    /// The selected vehicle
    @Published var selectedVehicle: String = ""
    
    
    // MARK: - User intends
    
    /// This will read all the vehicles from the API
    func readVehicles() async {
        guard let accessToken = UserDefaults.standard.accessToken else {
            logger.error("No access token saved")
            return
        }
        do {
            let vehicles = try await NiuAPI.vehicles(forUserWith: accessToken)
            DispatchQueue.main.async {
                self.vehicles = vehicles
                
                if let serialNumber = UserDefaults.standard.scooterSerialNumber, vehicles.contains(where: { $0.sn == serialNumber }) {
                    self.selectedVehicle = serialNumber
                }
            }
        } catch {
            if let error = error as? NiuAPI.Errors {
                logger.error("\(error.description, privacy: .public)")
            } else {
                logger.error("\(error.localizedDescription, privacy: .public)")
            }
        }
    }
    
    /// This will save the selected vehicle to the user defaults
    func saveSelectedVehicle() {
        UserDefaults.standard.scooterSerialNumber = selectedVehicle
    }
}

// MARK: - Preview data

extension VehiclePickerViewModel {
    static let preview: VehiclePickerViewModel = {
        let vm = VehiclePickerViewModel()
        
        return vm
    }()
}
