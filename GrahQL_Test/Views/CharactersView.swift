import SwiftUI
import SwiftData

//
//   CharactersView.swift
//  GrahQL_Test
//
//  Created by Angel Docampo on 31/8/25.
//

struct CharactersView: View {
    
    @StateObject private var viewModel: CharacterViewModel
    @Environment(\.modelContext) private var modelContext
    
    
    init() {
        // We'll initialize with a temporary context, it will be updated by the environment
        let container = try! ModelContainer(for: Character.self, Location.self, Episode.self)
        _viewModel = StateObject(wrappedValue: CharacterViewModel(modelContext: ModelContext(container)))
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.characters) { character in
                    VStack(alignment: .leading) {
                        AsyncImage(url: URL(string: character.image)) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 200)
                        } placeholder: {
                            ProgressView()
                        }
                        
                        Text(character.name)
                            .font(.headline)
                        
                        HStack {
                            Text(character.status)
                            Text("•")
                            Text(character.species)
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    }
                    .onAppear {
                        if character.id == viewModel.characters.last?.id {
                            print("Cheracter onAppear")
                            Task {
                                await viewModel.fetchCharacters()
                            }
                        }
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Characters")
            .task {
                // Update the view model's context when the view appears
                viewModel.modelContext = modelContext
                if viewModel.characters.isEmpty {
                    await viewModel.fetchCharacters()
                }
            }
        }
    }
}

#Preview {
    CharactersView()
        .modelContainer(for: [Character.self, Location.self, Episode.self], inMemory: true)
}
