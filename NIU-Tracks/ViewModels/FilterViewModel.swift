//
//  FilterViewModel.swift
//  NIU-Tracks
//
//  Created by Andre Albach on 17.06.23.
//

import Foundation

/// The view model for the filter view
@MainActor
final class FilterViewModel: ObservableObject {
    
    // MARK: - Driver
    
    @Published var selectedDriver: Driver? = UserDefaults.standard.filterSelectedDriver {
        didSet {
            UserDefaults.standard.filterSelectedDriver = selectedDriver
        }
    }
    
    // MARK: - Dates
    
    @Published var isStartDateActive: Bool = UserDefaults.standard.filterIsStartDateActive {
        didSet {
            UserDefaults.standard.filterIsStartDateActive = isStartDateActive
        }
    }
    @Published var startDate: Date = UserDefaults.standard.filterStarteDate {
        didSet {
            UserDefaults.standard.filterStarteDate = startDate
        }
    }
    @Published var isEndDateActive: Bool = UserDefaults.standard.filterIsEndDateActive {
        didSet {
            UserDefaults.standard.filterIsEndDateActive = isEndDateActive
        }
    }
    @Published var endDate: Date = UserDefaults.standard.filterEndDate {
        didSet {
            UserDefaults.standard.filterEndDate = endDate
        }
    }
    
    // MARK: - Route length
    
    @Published var isMinimumRouteLengthActive: Bool = UserDefaults.standard.filterIsMinimumRouteLengthActive {
        didSet {
            UserDefaults.standard.filterIsMinimumRouteLengthActive = isMinimumRouteLengthActive
        }
    }
    @Published var minimumRouteLength: String = UserDefaults.standard.filterMinimumRouteLength {
        didSet {
            UserDefaults.standard.filterMinimumRouteLength = minimumRouteLength
        }
    }
    @Published var isMaximumRouteLengthActive: Bool = UserDefaults.standard.filterIsMaximumRouteLengthActive {
        didSet {
            UserDefaults.standard.filterIsMaximumRouteLengthActive = isMaximumRouteLengthActive
        }
    }
    @Published var maximumRouteLength: String = UserDefaults.standard.filterMaximumRouteLength {
        didSet {
            UserDefaults.standard.filterMaximumRouteLength = maximumRouteLength
        }
    }
    
    // MARK: - Riding time
    
    @Published var isMinimumRidingTimeActive: Bool = UserDefaults.standard.filterIsMinimumRidingTimeActive {
        didSet {
            UserDefaults.standard.filterIsMinimumRidingTimeActive = isMinimumRidingTimeActive
        }
    }
    @Published var minimumRidingTime: String = UserDefaults.standard.filterMinimumRidingTime {
        didSet {
            UserDefaults.standard.filterMinimumRidingTime = minimumRidingTime
        }
    }
    @Published var isMaximumRidingTimeActive: Bool = UserDefaults.standard.filterIsMaximumRidingTimeActive {
        didSet {
            UserDefaults.standard.filterIsMaximumRidingTimeActive = isMaximumRidingTimeActive
        }
    }
    @Published var maximumRidingTime: String = UserDefaults.standard.filterMaximumRidingTime {
        didSet {
            UserDefaults.standard.filterMaximumRidingTime = maximumRidingTime
        }
    }
    
    /// Will return the filter values
    var filterValues: Filter {
        let startDate = isStartDateActive ? startDate : nil
        let endDate = isEndDateActive ? endDate : nil
        let minimumRouteLength = isMinimumRouteLengthActive ? Int(minimumRouteLength) : nil
        let maximumRouteLength = isMaximumRouteLengthActive ? Int(maximumRouteLength) : nil
        let minimumRidingTime = isMinimumRidingTimeActive ? Int(minimumRidingTime) : nil
        let maximumRidingTime = isMaximumRidingTimeActive ? Int(maximumRidingTime) : nil
        
        return Filter(driver: selectedDriver,
                      startDate: startDate,
                      endDate: endDate,
                      minimumRouteLength: minimumRouteLength,
                      maximumRouteLength: maximumRouteLength,
                      minimumRidingTime: minimumRidingTime,
                      maximumRidingTime: maximumRidingTime)
    }
}


// MARK: - Preview data

extension FilterViewModel {
    static let preview: FilterViewModel = {
        let viewModel = FilterViewModel()
        viewModel.selectedDriver = .me
        viewModel.isStartDateActive = true
        viewModel.startDate = Calendar.current.date(from: DateComponents(year: 2023, month: 6, day: 1))!.startOfTheDay
        viewModel.isEndDateActive = true
        viewModel.endDate = Calendar.current.date(from: DateComponents(year: 2023, month: 30, day: 1))!.endOfTheDay
        
        return viewModel
    }()
}
