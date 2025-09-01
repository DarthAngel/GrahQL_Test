import Foundation
import SwiftData

@MainActor
class CharacterViewModel: ObservableObject {
    @Published private(set) var characters: [Character] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var currentPage = 1
    private var hasMorePages = true
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchCharacters() async {
        guard !isLoading, hasMorePages else { return }
        
        isLoading = true
        error = nil
        
        do {
            // First try to load from local storage
            if currentPage == 1 {
                let descriptor = FetchDescriptor<Character>(sortBy: [SortDescriptor(\.name)])
                let localCharacters = try modelContext.fetch(descriptor)
                if !localCharacters.isEmpty {
                    characters = localCharacters
                    currentPage = localCharacters.count / 20 + 1 // Assuming 20 items per page
                    print("✅ Loaded \(localCharacters.count) characters from local storage")
                } else {
                    print("ℹ️ No local characters found, will fetch from API")
                }
            }
            
            print("🌐 Fetching characters page \(currentPage) from API...")
            let newCharacters = try await APIService.shared.fetchCharacters(page: currentPage, modelContext: modelContext)
            print("✅ Fetched \(newCharacters.count) characters from API")
            
            // Update the local cache
            if !newCharacters.isEmpty {
                if currentPage == 1 {
                    characters = newCharacters
                    print("🔄 Updated characters list with \(newCharacters.count) items")
                } else {
                    characters.append(contentsOf: newCharacters)
                    print("🔄 Appended \(newCharacters.count) new characters to existing list")
                }
                hasMorePages = !newCharacters.isEmpty
                currentPage += 1
                
                // Save the context
                try? modelContext.save()
                print("💾 Saved \(newCharacters.count) characters to local storage")
            } else {
                print("ℹ️ No new characters received from API")
                hasMorePages = false
            }
        } catch {
            print("❌ Error fetching characters: \(error.localizedDescription)")
            self.error = error
        }
        
        print("🏁 Fetch completed. Total characters: \(characters.count)")
        isLoading = false
    }
}
