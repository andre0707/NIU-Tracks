//
//  TrackPoint.swift
//  NIU-Tracks
//
//  Created by Andre Albach on 17.06.23.
//

import CoreLocation
import CoreData
import NiuAPI

extension CDTrackPoint {
    
    /// The location of the point
    var location: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
    
    
    // MARK: - Initialisation
    
    convenience init(context: NSManagedObjectContext, index: Int, trackPoint: TrackDetail.TrackPoint) {
        self.init(context: context)
        
        self.index = Int16(index)
        self.latitude = trackPoint.latitude
        self.longitude = trackPoint.longitude
        self.speed = Int16(trackPoint.speed)
        self.date = trackPoint.date
    }
}
