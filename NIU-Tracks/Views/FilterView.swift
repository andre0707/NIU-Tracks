//
//  FilterView.swift
//  NIU-Tracks
//
//  Created by Andre Albach on 17.06.23.
//

import SwiftUI

/// A view which provides all filter options
struct FilterView: View {
    
    /// Reference to the view model which drives the view
    @ObservedObject var filterViewModel: FilterViewModel
    
    /// Dismiss action
    @Environment(\.dismiss) private var dismiss
    
    /// The body
    var body: some View {
        Form {
            Section {
                Picker("Driver", selection: $filterViewModel.selectedDriver) {
                    Text("All")
                        .tag(nil as Driver?)
                    ForEach(Driver.allCases, id: \.self) { driver in
                        Text(verbatim: driver.description)
                            .tag(driver as Driver?)
                    }
                }
            }
            
            Section {
                DatePicker(selection: $filterViewModel.startDate,
                           label: {
                    Toggle("Start date",
                           isOn: $filterViewModel.isStartDateActive)
                })
                
                DatePicker(selection: $filterViewModel.endDate,
                           label: {
                    Toggle("End date",
                           isOn: $filterViewModel.isEndDateActive)
                })
            }
            
            Section {
                TextField(text: $filterViewModel.minimumRouteLength,
                          prompt: Text("Distance in meter"),
                          label: {
                    Toggle("Minimum route length", isOn: $filterViewModel.isMinimumRouteLengthActive)
                })
                
                TextField(text: $filterViewModel.maximumRouteLength,
                          prompt: Text("Distance in meter"),
                          label: {
                    Toggle("Maximum route length", isOn: $filterViewModel.isMaximumRouteLengthActive)
                })
                
                TextField(text: $filterViewModel.minimumRidingTime,
                          prompt: Text("Time in seconds"),
                          label: {
                    Toggle("Minimum riding time", isOn: $filterViewModel.isMinimumRidingTimeActive)
                })
                
                TextField(text: $filterViewModel.maximumRidingTime,
                          prompt: Text("Time in seconds"),
                          label: {
                    Toggle("Maximum riding time", isOn: $filterViewModel.isMaximumRidingTimeActive)
                })
            }
            
            HStack {
                Spacer()
                Button(action: {
                    dismiss()
                }, label: {
                    Text("Ok")
                        .frame(minWidth: 50)
                })
            }
        }
    }
}


// MARK: - Preview

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(filterViewModel: FilterViewModel.preview)
            .frame(width: 350)
            .padding()
    }
}
