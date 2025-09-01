//
//  EpisodeRow.swift
//  GrahQL_Test
//
//  Created by Angel Docampo on 31/8/25.
//

import SwiftUI
import SwiftData

struct EpisodeRow: View {
    let episode: Episode
    
    private var characterCount: Int {
        (episode.characterIds as? [String])?.count ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(episode.name)
                .font(.headline)
            
            HStack {
                Text(episode.episode)
                Text("•")
                Text(episode.airDate)
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            
            Text("\(characterCount) characters")
                .font(.caption)
                .foregroundColor(characterCount > 0 ? .blue : .gray)
        }
        .padding(.vertical, 8)
    }
}

struct EpisodesView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: EpisodeViewModel
    
    init() {
        let schema = Schema([
            Character.self,
            Location.self,
            Episode.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)
        _viewModel = StateObject(wrappedValue: EpisodeViewModel(modelContext: context))
    }
    
    private var episodesList: some View {
        ForEach(viewModel.episodes) { episode in
            EpisodeRow(episode: episode)
                .onAppear {
                    if episode.id == viewModel.episodes.last?.id {
                        Task { await viewModel.fetchEpisodes() }
                    }
                }
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                episodesList
                loadingView
            }
            .navigationTitle("Episodes")
            .refreshable { await viewModel.fetchEpisodes() }
            .task {
                viewModel.modelContext = modelContext
                if viewModel.episodes.isEmpty {
                    await viewModel.fetchEpisodes()
                }
            }
        }
    }
}

#Preview {
    EpisodesView()
        .modelContainer(for: [Character.self, Location.self, Episode.self], inMemory: true)
}
