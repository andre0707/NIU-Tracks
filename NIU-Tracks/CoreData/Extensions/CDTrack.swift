//
//  Track.swift
//  NIU-Tracks
//
//  Created by Andre Albach on 17.06.23.
//

import CoreLocation
import CoreData
import NiuAPI

// MARK: - Init

extension CDTrack {
    convenience init(context: NSManagedObjectContext, scooterSerialNumber: String, track: Track, trackDetail: TrackDetail) {
        self.init(context: context)
        
        self.scooterSerialNumber = scooterSerialNumber
        self.distance = Int32(track.distance)
        self.driver_ = Driver.someone.rawValue
        self.powerConsumption = Int16(track.powerConsumption)
        self.ridingTime = Int32(track.ridingTime)
        self.averageSpeed = track.averageSpeed
        self.endPointLatitude = track.lastPoint.latitude
        self.endPointLongitude = track.lastPoint.longitude
        self.startPointLatitude = track.startPoint.latitude
        self.startPointLongitude = track.startPoint.longitude
        self.trackId = track.trackId
        self.trackThumbnail = track.trackThumbnail
        self.endTime = track.endTime
        self.startTime = track.startTime
        
        let points = trackDetail.trackItems.enumerated().map { index, element in
            CDTrackPoint(context: context,
                         index: index,
                         trackPoint: element)
        }
        self.addToTrackPoints_(NSSet(array: points))
    }
}


// MARK: - Measurements

extension CDTrack {
    
    /// The distance as a measurement object
    var distanceMeasurement: Measurement<UnitLength> {
        Measurement(value: Double(distance), unit: UnitLength.meters)
    }
    
    /// The average speed as a measurement object
    var averageSpeedMeasurement: Measurement<UnitSpeed> {
        Measurement(value: averageSpeed, unit: UnitSpeed.kilometersPerHour)
    }
}


// MARK: - Helper variables

extension CDTrack {
    /// All the points of the track
    var points: [CLLocationCoordinate2D] {
        guard let trackPointsData = trackPoints_,
              let trackPoints = trackPointsData.allObjects as? [CDTrackPoint]
        else { return [] }
        
        return trackPoints
            .sorted(by: { $0.index < $1.index })
            .map { $0.location }
    }
    
    /// The driver who drove the track
    var driver: Driver {
        get { Driver(rawValue: driver_) ?? .someone }
        set { driver_ = newValue.rawValue }
    }
}


// MARK: - FetchRequests

extension CDTrack {
    
    /// A fetch request matching the passed in `filter`
    /// - Parameter scooterSerialNumber: The serial number of the scooter for which tracks are needed
    /// - Parameter filter: The filter
    /// - Parameter limit: Optional a limit
    /// - Returns: The resulting fetch request
    static func fetchRequest(scooterSerialNumber: String, filter: Filter, limit: Int? = nil) -> NSFetchRequest<CDTrack> {
        
        let fetchRequest = CDTrack.fetchRequest()
        
        if let limit = limit {
            fetchRequest.fetchLimit = limit
        }
        
        /// Scooter serial number
        let scooterSerialNumberPredicate: NSPredicate = NSPredicate(format: "%K = %@", argumentArray: [
            #keyPath(CDTrack.scooterSerialNumber),
            scooterSerialNumber
        ])
        
        /// The list of all sub predicates which need to be combined
        var subPredicates: [NSPredicate] = [scooterSerialNumberPredicate]
        
        /// Driver
        if let driver = filter.driver {
            let driverPredicate = NSPredicate(format: "%K = %d", argumentArray: [
                #keyPath(CDTrack.driver_),
                driver.rawValue
            ])
            subPredicates.append(driverPredicate)
        }
        
        /// Start time
        switch (filter.startDate != nil, filter.endDate != nil) {
        case (false, false):
            break
            
        case (true, false):
            let startTimePredicate = NSPredicate(format: "%K >= %@", argumentArray: [
                #keyPath(CDTrack.startTime),
                filter.startDate!
            ])
            subPredicates.append(startTimePredicate)
            
        case (false, true):
            let startTimePredicate = NSPredicate(format: "%K <= %@", argumentArray: [
                #keyPath(CDTrack.startTime),
                filter.endDate!
            ])
            subPredicates.append(startTimePredicate)
            
        case (true, true):
            let startTimePredicate = NSPredicate(format: "%K >= %@ && %K <= %@", argumentArray: [
                #keyPath(CDTrack.startTime),
                filter.startDate!,
                #keyPath(CDTrack.startTime),
                filter.endDate!
            ])
            subPredicates.append(startTimePredicate)
        }
        
        /// Distance
        switch (filter.minimumRouteLength != nil, filter.maximumRouteLength != nil) {
        case (false, false):
            break
            
        case (true, false):
            let distancePredicate = NSPredicate(format: "%K >= %d", argumentArray: [
                #keyPath(CDTrack.distance),
                filter.minimumRouteLength!
            ])
            subPredicates.append(distancePredicate)
            
        case (false, true):
            let distancePredicate = NSPredicate(format: "%K <= %d", argumentArray: [
                #keyPath(CDTrack.distance),
                filter.maximumRouteLength!
            ])
            subPredicates.append(distancePredicate)
            
        case (true, true):
            let distancePredicate = NSPredicate(format: "%K >= %d && %K <= %d", argumentArray: [
                #keyPath(CDTrack.distance),
                filter.minimumRouteLength!,
                #keyPath(CDTrack.distance),
                filter.maximumRouteLength!
            ])
            subPredicates.append(distancePredicate)
        }
        
        /// Riding time
        switch (filter.minimumRidingTime != nil, filter.maximumRidingTime != nil) {
        case (false, false):
            break
            
        case (true, false):
            let ridingTimePredicate = NSPredicate(format: "%K >= %d", argumentArray: [
                #keyPath(CDTrack.ridingTime),
                filter.minimumRidingTime!
            ])
            subPredicates.append(ridingTimePredicate)
            
        case (false, true):
            let ridingTimePredicate = NSPredicate(format: "%K <= %d", argumentArray: [
                #keyPath(CDTrack.ridingTime),
                filter.maximumRidingTime!
            ])
            subPredicates.append(ridingTimePredicate)
            
        case (true, true):
            let ridingTimePredicate = NSPredicate(format: "%K >= %d && %K <= %d", argumentArray: [
                #keyPath(CDTrack.ridingTime),
                filter.minimumRidingTime!,
                #keyPath(CDTrack.ridingTime),
                filter.maximumRidingTime!
            ])
            subPredicates.append(ridingTimePredicate)
        }
        
        fetchRequest.predicate = subPredicates.count > 1 ? NSCompoundPredicate(andPredicateWithSubpredicates: subPredicates) : scooterSerialNumberPredicate
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(CDTrack.startTime), ascending: false)
        ]
        
        return fetchRequest
    }
    
    /// A fetch request to read all tracks
    /// - Parameter scooterSerialNumber: The serial number of the scooter for which tracks are needed
    /// - Parameter limit: Optional a limit
    /// - Returns: The resulting fetch request
    static func fetchRequest(scooterSerialNumber: String, limit: Int? = nil) -> NSFetchRequest<CDTrack> {
        
        let fetchRequest = CDTrack.fetchRequest()
        
        if let limit = limit {
            fetchRequest.fetchLimit = limit
        }
        
        /// Scooter serial number
        let scooterSerialNumberPredicate: NSPredicate = NSPredicate(format: "%K = %@", argumentArray: [
            #keyPath(CDTrack.scooterSerialNumber),
            scooterSerialNumber
        ])
        
        fetchRequest.predicate = scooterSerialNumberPredicate
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(CDTrack.startTime), ascending: false)
        ]
        
        return fetchRequest
    }
    
    /// A fetch request to read all tracks which id match `trackIds`
    /// - Parameter scooterSerialNumber: The serial number of the scooter for which tracks are needed
    /// - Parameter trackIds: The list of ids for which the tracks should be read
    /// - Parameter limit: Optional a limit
    /// - Returns: The resulting fetch request
    static func fetchRequest(scooterSerialNumber: String, matching trackIds: [String], limit: Int? = nil) -> NSFetchRequest<CDTrack> {
        
        let fetchRequest = CDTrack.fetchRequest()
        
        if let limit = limit {
            fetchRequest.fetchLimit = limit
        }
        
        /// Scooter serial number
        let scooterSerialNumberPredicate: NSPredicate = NSPredicate(format: "%K = %@", argumentArray: [
            #keyPath(CDTrack.scooterSerialNumber),
            scooterSerialNumber
        ])
        
        /// Track ids
        let trackIdsPredicate = NSPredicate(format: "%K IN (%@)", argumentArray: [
            #keyPath(CDTrack.trackId),
            trackIds
        ])
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [scooterSerialNumberPredicate, trackIdsPredicate])
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(CDTrack.startTime), ascending: false) /// Get the newest downloaded track first
        ]
        
        return fetchRequest
    }
    
    /// A fetch request to read all tracks shorter than `maxDistance`
    /// - Parameters:
    ///   - scooterSerialNumber: The serial number of the scooter for which tracks are needed
    ///   - maxDistance: The maximum distance a track can have to match
    ///   - limit: Optional a limit
    /// - Returns: The resulting fetch request
    static func fetchRequest(scooterSerialNumber: String, maxDistance: Double = 10, limit: Int? = nil) -> NSFetchRequest<CDTrack> {
        let fetchRequest = CDTrack.fetchRequest()
        
        if let limit = limit {
            fetchRequest.fetchLimit = limit
        }
        
        /// Scooter serial number
        let scooterSerialNumberPredicate: NSPredicate = NSPredicate(format: "%K = %@", argumentArray: [
            #keyPath(CDTrack.scooterSerialNumber),
            scooterSerialNumber
        ])
        
        /// Distance
        let distancePredicate = NSPredicate(format: "%K < %f", argumentArray: [
            #keyPath(CDTrack.distance),
            maxDistance
        ])
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [scooterSerialNumberPredicate, distancePredicate])
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(CDTrack.startTime), ascending: false)
        ]
        
        return fetchRequest
    }
    
    /// A fetch request to read all tracks for the specified `driver`
    /// - Parameters:
    ///   - scooterSerialNumber: The serial number of the scooter for which tracks are needed
    ///   - driver: The driver who drove the tracks
    ///   - limit: Optional a limit
    /// - Returns: The resulting fetch request
    static func fetchRequest(scooterSerialNumber: String, for driver: Driver?, limit: Int? = nil) -> NSFetchRequest<CDTrack> {
        let fetchRequest = CDTrack.fetchRequest()
        
        if let limit = limit {
            fetchRequest.fetchLimit = limit
        }
        
        /// Scooter serial number
        let scooterSerialNumberPredicate: NSPredicate = NSPredicate(format: "%K = %@", argumentArray: [
            #keyPath(CDTrack.scooterSerialNumber),
            scooterSerialNumber
        ])
        
        /// Driver
        if let driver = driver {
            let driverPredicate = NSPredicate(format: "%K = %d", argumentArray: [
                #keyPath(CDTrack.driver_),
                driver.rawValue
            ])
            
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [scooterSerialNumberPredicate, driverPredicate])
        } else {
            fetchRequest.predicate = scooterSerialNumberPredicate
        }
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(CDTrack.startTime), ascending: false)
        ]
        
        return fetchRequest
    }
}
