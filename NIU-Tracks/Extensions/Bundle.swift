//
//  Bundle.swift
//  NIU-Tracks
//
//  Created by Andre Albach on 17.06.23.
//

import Foundation

extension Bundle {
    /// The external release number
    var releaseVersionNumber: String? { infoDictionary?["CFBundleShortVersionString"] as? String }
    
    /// The internal release number
    var buildVersionNumber: String? { infoDictionary?["CFBundleVersion"] as? String }
    
    /// The name of the app
    var displayName: String? {
        if let bundleDisplayName = infoDictionary?["CFBundleDisplayName"] as? String { return bundleDisplayName }
        return infoDictionary?[kCFBundleNameKey as String] as? String
    }
    
    /// The bundle identifier. So something like "de.aaindustries.#APPNAME"
    var bundleIdentifier: String { (infoDictionary?["CFBundleIdentifier"] as? String) ?? ""}
    
    /// A list of all the quick action identifiers
    var quickActionIdentifier: [String] {
        guard let items = infoDictionary?["UIApplicationShortcutItems"] as? [Dictionary<String, String>] else { return [] }
        return items.compactMap { $0["UIApplicationShortcutItemType"] }
    }
}
