//
//  MainViewSheets.swift
//  NIU-Tracks
//
//  Created by Andre Albach on 17.06.23.
//

import Foundation

/// A list of all the sheets which can be presented
enum MainViewSheets: Identifiable {
    /// Presents a sheet which shows the login view
    case login
    /// Presents a sheet which shows the vehicle picker view
    case vehiclePicker
    
    var id: Self { self }
}
