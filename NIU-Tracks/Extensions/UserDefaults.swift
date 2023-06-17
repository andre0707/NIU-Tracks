//
//  UserDefaults.swift
//  NIU-Tracks
//
//  Created by Andre Albach on 17.06.23.
//

import Foundation

extension UserDefaults {
    
    // MARK: - Keys
    
    /// Lists all keys used to store user defaults
    enum Keys {
        static let countryCode = "countryCode"
        static let account = "account"
        static let refreshToken = "refreshToken"
        static let accessToken = "accessToken"
        
        static let scooterSerialNumber = "scooterSerialNumber"
        
        static let lastDownloadFromApiDate = "lastDownloadFromApiDate"
        
        /// Last used filter
        static let filterSelectedDriver = "filterSelectedDriver"
        static let filterIsStartDateActive = "filterIsStartDateActive"
        static let filterStarteDate = "filterStarteDate"
        static let filterIsEndDateActive = "filterIsEndDateActive"
        static let filterEndDate = "filterEndDate"
        static let filterIsMinimumRouteLengthActive = "filterIsMinimumRouteLengthActive"
        static let filterMinimumRouteLength = "filterMinimumRouteLength"
        static let filterIsMaximumRouteLengthActive = "filterIsMaximumRouteLengthActive"
        static let filterMaximumRouteLength = "filterMaximumRouteLength"
        static let filterIsMinimumRidingTimeActive = "filterIsMinimumRidingTimeActive"
        static let filterMinimumRidingTime = "filterMinimumRidingTime"
        static let filterIsMaximumRidingTimeActive = "filterIsMaximumRidingTimeActive"
        static let filterMaximumRidingTime = "filterMaximumRidingTime"
    }
    
    // MARK: - Account settings
    
    var countryCode: Int {
        get { object(forKey: Keys.countryCode, withDefault: 49) }
        set { setValue(newValue, forKey: Keys.countryCode) }
    }
    var account: String? {
        get { string(forKey: Keys.account) }
        set { setValue(newValue, forKey: Keys.account) }
    }
    var refreshToken: String? {
        get { string(forKey: Keys.refreshToken) }
        set { setValue(newValue, forKey: Keys.refreshToken) }
    }
    var accessToken: String? {
        get { string(forKey: Keys.accessToken) }
        set { setValue(newValue, forKey: Keys.accessToken) }
    }
    
    var scooterSerialNumber: String? {
        get { string(forKey: Keys.scooterSerialNumber) }
        set { setValue(newValue, forKey: Keys.scooterSerialNumber) }
    }
    
    func resetAccess() {
        refreshToken = nil
        accessToken = nil
        scooterSerialNumber = nil
    }
    
    var lastDownloadFromApiDate: Date? {
        get { object(forKey: Keys.lastDownloadFromApiDate) as? Date }
        set { setValue(newValue, forKey: Keys.lastDownloadFromApiDate) }
    }
    
    
    // MARK: - Last filter
    
    var filterSelectedDriver: Driver? {
        get {
            guard let rawValue = object(forKey: Keys.filterSelectedDriver) as? Int16 else { return nil }
            return Driver(rawValue: rawValue)
        }
        set { setValue(newValue?.rawValue, forKey: Keys.filterSelectedDriver) }
    }
    var filterIsStartDateActive: Bool {
        get { bool(forKey: Keys.filterIsStartDateActive) }
        set { setValue(newValue, forKey: Keys.filterIsStartDateActive) }
    }
    var filterStarteDate: Date {
        get { object(forKey: Keys.filterStarteDate, withDefault: Date.startOfThisMonth) }
        set { setValue(newValue, forKey: Keys.filterStarteDate) }
    }
    var filterIsEndDateActive: Bool {
        get { bool(forKey: Keys.filterIsEndDateActive) }
        set { setValue(newValue, forKey: Keys.filterIsEndDateActive) }
    }
    var filterEndDate: Date {
        get { object(forKey: Keys.filterEndDate, withDefault: Date.now) }
        set { setValue(newValue, forKey: Keys.filterEndDate) }
    }
    var filterIsMinimumRouteLengthActive: Bool {
        get { bool(forKey: Keys.filterIsMinimumRouteLengthActive) }
        set { setValue(newValue, forKey: Keys.filterIsMinimumRouteLengthActive) }
    }
    var filterMinimumRouteLength: String {
        get { object(forKey: Keys.filterMinimumRouteLength, withDefault: "") }
        set { setValue(newValue, forKey: Keys.filterMinimumRouteLength) }
    }
    var filterIsMaximumRouteLengthActive: Bool {
        get { bool(forKey: Keys.filterIsMaximumRouteLengthActive) }
        set { setValue(newValue, forKey: Keys.filterIsMaximumRouteLengthActive) }
    }
    var filterMaximumRouteLength: String {
        get { object(forKey: Keys.filterMaximumRouteLength, withDefault: "") }
        set { setValue(newValue, forKey: Keys.filterMaximumRouteLength) }
    }
    var filterIsMinimumRidingTimeActive: Bool {
        get { bool(forKey: Keys.filterIsMinimumRidingTimeActive) }
        set { setValue(newValue, forKey: Keys.filterIsMinimumRidingTimeActive) }
    }
    var filterMinimumRidingTime: String {
        get { object(forKey: Keys.filterMinimumRidingTime, withDefault: "") }
        set { setValue(newValue, forKey: Keys.filterMinimumRidingTime) }
    }
    var filterIsMaximumRidingTimeActive: Bool {
        get { bool(forKey: Keys.filterIsMaximumRidingTimeActive) }
        set { setValue(newValue, forKey: Keys.filterIsMaximumRidingTimeActive) }
    }
    var filterMaximumRidingTime: String {
        get { object(forKey: Keys.filterMaximumRidingTime, withDefault: "") }
        set { setValue(newValue, forKey: Keys.filterMaximumRidingTime) }
    }
}



extension UserDefaults {
    
    /// This function extends the existing get object function to pass in a default value and also the option to use the `AppSetting` enum instead of strings as the key
    /// - Parameters:
    ///   - key: The key under which the setting will be stored
    ///   - defaultValue: This value will be used if there is nothing saved for `key` yet
    /// - Returns: The stored value for `key` if there is one. `defaultValue` otherwise
    func object<T>(forKey key: String, withDefault defaultValue: T) -> T {
        return (self.object(forKey: key) as? T) ?? defaultValue
    }
}
