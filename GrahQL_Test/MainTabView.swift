//
//  MainTabView.swift
//  GrahQL_Test
//
//  Created by Angel Docampo on 31/8/25.
//

import SwiftUI
import SwiftData



struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            CharactersView()
                .environment(\.modelContext, modelContext)
                .tabItem {
                    Label("Characters", systemImage: "person.3")
                }
            
            LocationsView()
                .environment(\.modelContext, modelContext)
                .tabItem {
                    Label("Locations", systemImage: "map")
                }
            
            EpisodesView()
                .environment(\.modelContext, modelContext)
                .tabItem {
                    Label("Episodes", systemImage: "tv")
                }
        }
    }
}
#Preview {
    MainTabView()
}
