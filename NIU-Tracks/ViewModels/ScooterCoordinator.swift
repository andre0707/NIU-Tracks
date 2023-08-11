//
//  ScooterCoordinator.swift
//  NIU-Tracks
//
//  Created by Andre Albach on 17.06.23.
//

import Foundation
import NiuAPI
import os

/// A logger to log errors
fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier, category: "ScooterCoordinator")

/// The main scooter app coordinator
@MainActor
final class ScooterCoordinator: ObservableObject {
    
    /// Reference to the login view model
    let loginViewModel = LoginViewModel()
    
    /// Reference to the filter view model
    let filterViewModel = FilterViewModel()
    
    /// Indicator, if the filter is currently presented or not
    @Published var presentFilter: Bool = false {
        didSet {
            guard !presentFilter else { return }
            readTracksFromDatabase()
        }
    }
    
    /// The current presented sheet, if there is any
    @Published var presentedSheet: MainViewSheets? = (UserDefaults.standard.accessToken?.isEmpty ?? true) ? .login : nil
    
    
    // MARK: - Initialisation
    
    init() {
        readTracksFromDatabase()
    }
    
    
    // MARK: - Database
    
    /// A list of all the tracks which should be displayed
    @Published private(set) var tracks: [CDTrack] = []
    
    
    /// Will read all the tracks from the database
    @MainActor
    func readTracksFromDatabase() {
        do {
            tracks = try CoreDataStack.shared.viewContext.fetch(CDTrack.fetchRequest(scooterSerialNumber: UserDefaults.standard.scooterSerialNumber ?? "",
                                                                                     filter: filterViewModel.filterValues,
                                                                                     limit: nil))
            logger.info("Read \(self.tracks.count, privacy: .public) tracks read from database")
        } catch {
            logger.error("Error fetching tracks")
            tracks = []
        }
    }
    
    /// The amount of tracks which match the current filter
    var tracksCount: Int { tracks.count }
    /// The total distance of all tracks matchuing the current filter
    var totalTrackDistance: String {
        let totalDistance = tracks.reduce(into: 0, { $0 += $1.distance })
        return MeasurementFormatter().string(from: Measurement(value: Double(totalDistance), unit: UnitLength.meters))
    }
    
    
    // MARK: - Reading from API
    
    /// Indicator, if data is currently read from the API
    @Published private(set) var isReadingDataFromAPI: Bool = false
    
    /// Indicator, if the alert which shows a message sould be displayed
    @Published var presentMessageAlert: Bool = false {
        didSet {
            if !presentMessageAlert {
                alertMessage = ""
            }
        }
    }
    /// The message displayed in the alert
    @Published private(set) var alertMessage: String = "" {
        didSet {
            guard !alertMessage.isEmpty else { return }
            presentMessageAlert = true
        }
    }
    
    /// Will read data from the API
    func readFromAPI(readAll: Bool) async {
        guard let scooterSerialNumber = UserDefaults.standard.scooterSerialNumber,
              let accessToken = UserDefaults.standard.accessToken
        else {
            let message = String(localized: "Could not read tracks from API. Serial number of scooter or access token is not set.")
            logger.error("\(message, privacy: .public)")
            DispatchQueue.main.async {
                self.alertMessage = message
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isReadingDataFromAPI = true
        }
        defer {
            DispatchQueue.main.async {
                self.isReadingDataFromAPI = false
            }
        }
        
        var counterTotalAddedTracks = 0
        defer {
            DispatchQueue.main.async {
                let message: String
                if counterTotalAddedTracks > 0 {
                    message = String(localized: "Read \(counterTotalAddedTracks) tracks from the API and stored them to the database.")
                } else {
                    message = String(localized: "There were no new tracks available on the API.")
                }
                
                if self.alertMessage.isEmpty {
                    self.alertMessage = message
                } else {
                    self.alertMessage += "\n\n" + message
                }
            }
        }
        
        var page = 0
        while true {
            defer { page += 1 }
            
            do {
                let trackList = try await NiuAPI.tracks(forVehicleWith: scooterSerialNumber, take: 10, skip: page, accessToken: accessToken).items
                logger.info("\(trackList.count, privacy: .public) tracks read from NIU API")
                guard !trackList.isEmpty else {
                    UserDefaults.standard.lastDownloadFromApiDate = Date.now
                    return
                }
                
                /// Check if the tracks already exist
                let idsOfExistingTracks: Set<String>
                do {
                    let trackIds = trackList.map { $0.trackId }
                    let existingTracksFetchRequest = CDTrack.fetchRequest(scooterSerialNumber: UserDefaults.standard.scooterSerialNumber ?? "",
                                                                          matching: trackIds)
                    let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
                    idsOfExistingTracks = Set(try backgroundContext.fetch(existingTracksFetchRequest).compactMap { $0.trackId })
                    backgroundContext.reset()
                } catch {
                    idsOfExistingTracks = []
                    logger.error("Error fetching existing tracks from database")
                    DispatchQueue.main.async {
                        self.alertMessage = String(localized: "Error fetching existing tracks from database")
                    }
                }
                                
                let workingContext = CoreDataStack.shared.container.newBackgroundContext()
                var counterAddedTracksFromPage = 0
                defer {
                    workingContext.save(with: .downloadFromAPI)
                    counterTotalAddedTracks += counterAddedTracksFromPage
                    logger.info("Added \(counterAddedTracksFromPage, privacy: .public) new tracks to the database")
                }
                for track in trackList {
                    /// Track too old
                    if !readAll, let lastDownloadDate = UserDefaults.standard.lastDownloadFromApiDate,
                       track.startTime < lastDownloadDate {
                        logger.info("Canceled reading tracks with track at \(track.startTime, privacy: .public). Older tracks already downloaded.")
                        UserDefaults.standard.lastDownloadFromApiDate = Date.now
                        return
                    }
                    
                    let trackId = track.trackId
                    /// Track already stored
                    guard !idsOfExistingTracks.contains(trackId) else { continue }
                    
                    let trackDate = track.date
                    
                    do {
                        let trackDetails = try await NiuAPI.detailTrack(forVehicleWith: scooterSerialNumber, trackId: trackId, trackDate: trackDate, accessToken: accessToken)
                        
                        _ = CDTrack(context: workingContext,
                                    scooterSerialNumber: scooterSerialNumber,
                                    track: track,
                                    trackDetail: trackDetails)
                        
                        counterAddedTracksFromPage += 1
                        
                    } catch {
                        if let error = error as? NiuAPI.Errors {
                            logger.error("Error reading details to track with id: \(track.trackId, privacy: .public). Error: \(error.description, privacy: .public)")
                        } else {
                            logger.error("Error reading details to track with id: \(track.trackId, privacy: .public). Error: \(error, privacy: .public)")
                        }
                        
                        DispatchQueue.main.async {
                            self.alertMessage = String(localized: "Error reading details to track.")
                        }
                    }
                }
                
            } catch {
                if let error = error as? NiuAPI.Errors {
                    logger.error("\(error.description, privacy: .public)")
                    DispatchQueue.main.async {
                        self.alertMessage = error.description
                    }
                } else {
                    logger.error("\(error, privacy: .public)")
                    DispatchQueue.main.async {
                        self.alertMessage = error.localizedDescription
                    }
                }
                return
            }
        }
    }
    
    
    // MARK: - Track evaluation
    
    /// Will do an evaluation of the saved tracks
    private func evaluateTracks() {
        if tracks.isEmpty {
            readTracksFromDatabase()
        }
        
        var data: [String: Int] = [:]
        
        for track in tracks {
            let components = Calendar.current.dateComponents([.day, .year, .month], from: track.startTime!)
            let day = components.day!
            let month = components.month!
            
            let dateId = "\(components.year!)-\(month < 10 ? "0\(month)" : "\(month)")-\(day < 10 ? "0\(day)" : "\(day)")"
            let distance = Int(track.distance)
            data[dateId, default: 0] += distance
        }
        
        let sorted = data.sorted(by: { $0.key > $1.key })
        print(sorted)
    }
}


// MARK: - Preview

extension ScooterCoordinator {
    static var preview: ScooterCoordinator = {
        let coordinator = ScooterCoordinator()
        
        return coordinator
    }()
}
