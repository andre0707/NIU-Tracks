//
//  Driver.swift
//  NIU-Tracks
//
//  Created by Andre Albach on 17.06.23.
//

import Foundation

/// A list of all available drivers.
/// Will be saved with each track. By default `somone` will be stored.
enum Driver: Int16, CaseIterable, CustomStringConvertible {
    case someone = 0
    case me = 1
    
    var description: String {
        switch self {
        case .someone: return String(localized: "Someone")
        case .me: return String(localized: "Me")
        }
    }
}
