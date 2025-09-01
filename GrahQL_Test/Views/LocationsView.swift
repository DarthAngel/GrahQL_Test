//
//  LocationsView.swift
//  GrahQL_Test
//
//  Created by Angel Docampo on 31/8/25.
//

import SwiftUI
import SwiftData

struct LocationsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: LocationViewModel
    
    init() {
        // Create a temporary model container
        let schema = Schema([
            Character.self,
            Location.self,
            Episode.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        
        // Initialize the view model
        let context = ModelContext(container)
        _viewModel = StateObject(wrappedValue: LocationViewModel(modelContext: context))
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.locations) { location in
                    LocationRow(location: location)
                        .onAppear {
                            if location.id == viewModel.locations.last?.id {
                                Task {
                                    await viewModel.fetchLocations()
                                }
                            }
                        }
                }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Locations")
            .refreshable {
                await viewModel.fetchLocations()
            }
            .task {
                // Update the view model's context when the view appears
                viewModel.modelContext = modelContext
                if viewModel.locations.isEmpty {
                    await viewModel.fetchLocations()
                }
            }
        }
    
}

#Preview {
    LocationsView()
        .modelContainer(for: [Character.self, Location.self, Episode.self], inMemory: true)
}
