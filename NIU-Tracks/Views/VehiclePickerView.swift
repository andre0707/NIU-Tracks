//
//  VehiclePickerView.swift
//  NIU-Tracks
//
//  Created by Andre Albach on 17.06.23.
//

import NiuAPI
import SwiftUI

/// A simple view which allows to pick a scooter
struct VehiclePickerView: View {
    
    /// Reference to the vehicle picker view model
    @StateObject private var vehiclePickerViewModel = VehiclePickerViewModel()
    
    /// Dismiss action
    @Environment(\.dismiss) private var dismiss
    
    /// The body
    var body: some View {
        VStack {
            Text("Pick your vehicle")
                .font(.largeTitle)
            
            HStack {
                Text("Vehicle")
                Picker("", selection: $vehiclePickerViewModel.selectedVehicle) {
                    ForEach(vehiclePickerViewModel.vehicles, id: \.sn) { vehicle in
                        Text(verbatim: vehicle.name)
                            .tag(vehicle.sn)
                    }
                }
            }
            .disabled(vehiclePickerViewModel.vehicles.isEmpty)
            
            HStack {
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                
                Button("Load vehicles") {
                    Task {
                        await vehiclePickerViewModel.readVehicles()
                    }
                }
                
                Button("Save selected vehicle") {
                    vehiclePickerViewModel.saveSelectedVehicle()
                    dismiss()
                }
                .disabled(vehiclePickerViewModel.vehicles.isEmpty)
            }
        }
        .padding()
    }
}


// MARK: - Preview

struct ScooterPickerView_Previews: PreviewProvider {
    static var previews: some View {
        VehiclePickerView()
            .frame(width: 600, height: 400)
    }
}
