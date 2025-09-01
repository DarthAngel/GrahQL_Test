import Foundation
import SwiftData

@MainActor
class LocationViewModel: ObservableObject {
    @Published private(set) var locations: [Location] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var currentPage = 1
    private var hasMorePages = true
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchLocations() async {
        guard !isLoading, hasMorePages else { return }
        
        isLoading = true
        error = nil
        
        do {
            // First try to load from local storage
            if currentPage == 1 {
                var descriptor = FetchDescriptor<Location>(
                    sortBy: [SortDescriptor(\.name)]
                )
                descriptor.fetchLimit = 20 * currentPage // Only fetch what we need
                
                let localLocations = try modelContext.fetch(descriptor)
                if !localLocations.isEmpty {
                    locations = localLocations
                    currentPage = (localLocations.count / 20) + 1
                    hasMorePages = localLocations.count >= 20
                }
            }
            
            // Then fetch from API
            let newLocations = try await APIService.shared.fetchLocations(
                page: currentPage,
                modelContext: modelContext
            )
            
            // Update the local cache
            if !newLocations.isEmpty {
                // Use a task to perform updates on the main actor
                await MainActor.run {
                    if currentPage == 1 {
                        locations = newLocations
                    } else {
                        locations.append(contentsOf: newLocations)
                    }
                    hasMorePages = newLocations.count >= 20
                    currentPage += 1
                }
                
                // Save the context in a background task
                try? await Task.detached { [modelContext] in
                    try modelContext.save()
                }.value
            }
        } catch {
            await MainActor.run {
                self.error = error
                print("❌ Error fetching locations: \(error.localizedDescription)")
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
}
