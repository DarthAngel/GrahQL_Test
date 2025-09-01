import Foundation
import SwiftData

@MainActor
class EpisodeViewModel: ObservableObject {
    @Published private(set) var episodes: [Episode] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var currentPage = 1
    private var hasMorePages = true
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchEpisodes() async {
        guard !isLoading, hasMorePages else { return }
        
        isLoading = true
        error = nil
        
        do {
            // First try to load from local storage
            if currentPage == 1 {
                let descriptor = FetchDescriptor<Episode>(sortBy: [SortDescriptor(\.name)])
                let localEpisodes = try modelContext.fetch(descriptor)
                if !localEpisodes.isEmpty {
                    episodes = localEpisodes
                    currentPage = localEpisodes.count / 20 + 1 // Assuming 20 items per page
                }
            }
            
            // Then fetch from API
            let newEpisodes = try await APIService.shared.fetchEpisodes(page: currentPage, modelContext: modelContext)
            
            // Update the local cache
            if !newEpisodes.isEmpty {
                if currentPage == 1 {
                    episodes = newEpisodes
                } else {
                    episodes.append(contentsOf: newEpisodes)
                }
                hasMorePages = !newEpisodes.isEmpty
                currentPage += 1
                
                // Save the context
                try? modelContext.save()
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}
