//
//  MapViewRepresentable.swift
//  NIU-Tracks
//
//  Created by Andre Albach on 17.06.23.
//

import MapKit
import SwiftUI


/// A  view which represents a map
struct MapViewRepresentable: NSViewRepresentable {

    /// The represented NSView type
    public typealias NSViewType = MKMapView
    
    /// The lab adventure coordinator which handles lab adventure interactions. The displayed annotations usually come from here
    @ObservedObject var scooterCoordinator: ScooterCoordinator
    
    
    /// Creates the NSView with the SwiftUI data
    /// - Parameter context: The context
    /// - Returns: The resulting NSView
    func makeNSView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        mapView.showsBuildings = false
        mapView.showsTraffic = false
        mapView.showsCompass = true
        mapView.showsZoomControls = true
        
        mapView.showsUserLocation = true
        
        
        mapView.pointOfInterestFilter = .excludingAll
        mapView.mapType = .mutedStandard
        
        addTracks(to: mapView)
        
        return mapView
    }
    
    /// Update the NSView with new data from SwiftUI
    /// - Parameters:
    ///   - uiView: The NSView which needs to be updated
    ///   - context: The context
    func updateNSView(_ nsView: MKMapView, context: Context) {
        
        addTracks(to: nsView)
    }
    
    /// Creates the coordinator
    /// - Returns: The view coordinator
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator(scooterCoordinator: scooterCoordinator)
    }
    
    private func addTracks(to mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        
        let polylines = scooterCoordinator.tracks.map {
            let points = $0.points
            return MKPolyline(coordinates: points, count: points.count)
        }
        
        mapView.addOverlay(MKMultiPolyline(polylines))
        zoomToOverlays(mapView: mapView)
    }
    
    /// This function will zoom the map, so that all the routes are visible
    private func zoomToOverlays(mapView: MKMapView) {
        guard var mapRect = mapView.overlays.first?.boundingMapRect else { return }
        
        let insets = NSEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        
//        let mapRectComplete = mapView.overlays
//            .dropFirst() /// Drop first, because its already in `initial`
//            .reduce(initial) { $0.union($1.boundingMapRect) }
        
        let remainingOverlays = mapView.overlays.dropFirst()
        for overlay in remainingOverlays {
            mapRect = mapRect.union(overlay.boundingMapRect)
            
//            /// Limit the zoom out rect to 0.75° in longitude. This will help with memory warnings
//            let minX = MKMapPoint(x: mapRect.origin.x, y: mapRect.origin.y).coordinate
//            let maxX = MKMapPoint(x: mapRect.origin.x + mapRect.width, y: mapRect.origin.y).coordinate
//            if abs(maxX.longitude - minX.longitude) > 0.75 { break }
        }
        
        DispatchQueue.main.async {
            mapView.setVisibleMapRect(mapRect, edgePadding: insets, animated: true)
        }
    }
    
    
    
    // MARK: - The coordinator of this view
    
    /// The coordinator for the map view
    final class MapViewCoordinator: NSObject, MKMapViewDelegate {
        
        /// Reference to the lab adventure coordinator which does the processing and handles interactions
        private let scooterCoordinator: ScooterCoordinator
        
        /// The width of the lines which represent the routes
        private let lineWidth: CGFloat = 1
        
        /// Init function
        /// - Parameter mapDataViewModel: map view model to use
        init(scooterCoordinator: ScooterCoordinator) {
            self.scooterCoordinator = scooterCoordinator
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            
            if let multiPolyline = overlay as? MKMultiPolyline {
                let renderer = MKMultiPolylineRenderer(multiPolyline: multiPolyline)
                renderer.lineWidth = lineWidth
                renderer.strokeColor = .red
                
                return renderer
            }
            
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.lineWidth = lineWidth
                renderer.strokeColor = .red
                
                return renderer
            }
            
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

