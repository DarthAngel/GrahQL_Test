//
//  GrahQL_TestApp.swift
//  GrahQL_Test
//
//  Created by Angel Docampo on 31/8/25.
//

import SwiftUI
import SwiftData
import Combine

@main
struct GrahQL_TestApp: App {
    @State private var isReady = false
    @State private var modelContainer: ModelContainer?
    
    init() {
        // Register the transformer before anything else
        StringArrayTransformer.register()
        
        // Verify registration
        let isRegistered = ValueTransformer.valueTransformerNames().contains { 
            $0.rawValue == StringArrayTransformer.name.rawValue
        }
        print("StringArrayTransformer registered:", isRegistered)
        
        // Initialize model container after transformer is registered
        do {
            let schema = Schema([
                Character.self,
                Location.self,
                Episode.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            
            _modelContainer = State(initialValue: try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            ))
            
            print("ModelContainer created successfully")
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if let modelContainer = modelContainer {
                MainTabView()
                    .modelContainer(modelContainer)
            } else {
                ProgressView("Loading...")
            }
        }
    }
}


