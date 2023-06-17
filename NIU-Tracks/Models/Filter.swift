//
//  Filter.swift
//  NIU-Tracks
//
//  Created by Andre Albach on 17.06.23.
//

import Foundation

/// A helper struct for all the filter values
struct Filter {
    /// The driver for who the tracks should be shown. If `nil`, all driver will be used
    let driver: Driver?
    
    /// The start date
    let startDate: Date?
    /// The end date
    let endDate: Date?
    
    /// The minimum route length
    let minimumRouteLength: Int?
    /// The maximum route length
    let maximumRouteLength: Int?
    
    /// The minimum riding time
    let minimumRidingTime: Int?
    /// The maximum riding time
    let maximumRidingTime: Int?
}
