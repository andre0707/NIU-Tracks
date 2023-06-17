//
//  ContextSaveContextualInfo.swift
//  NIU-Tracks
//
//  Created by Andre Albach on 17.06.23.
//

import Foundation

/// A list which provides context to a save actions.
/// This is used to have some kind of context what is saved and will help to find problems easier when something goes wrong.
enum ContextSaveContextualInfo: String {
    
    /// There were new tracks downloaded from the online API.
    case downloadFromAPI = "downloadFromAPI"
    /// The driver was changed
    case driverChanged = "driverChanged"
}
