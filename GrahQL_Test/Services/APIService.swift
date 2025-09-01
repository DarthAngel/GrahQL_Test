//  APIService.swift
//  GrahQL_Test
//
//  Created by Angel Docampo on 30/8/25.
//


import Foundation
import SwiftData

enum APIError: Error {
    case invalidURL
    case requestFailed
    case invalidResponse
    case decodingError
}


class APIService {
    static let shared = APIService()
    private let baseURL = "https://rickandmortyapi.com/graphql"
    
    private init() {}
    
    func fetchCharacters(page: Int = 1, modelContext: ModelContext? = nil) async throws -> [Character] {
        let query = """
        query {
          characters(page: \(page)) {
            info {
              count
              pages
              next
              prev
            }
            results {
              id
              name
              status
              species
              type
              gender
              image
              created
            }
          }
        }
        """
        
        struct Response: Decodable {
            let data: Data
            
            struct Data: Decodable {
                let characters: Characters
                
                struct Characters: Decodable {
                    let results: [Character]
                }
            }
        }
        
        let response: Response = try await performRequest(query: query, path: [])
        let characters = response.data.characters.results
        
        if let modelContext = modelContext {
            print("💾 Saving \(characters.count) characters to SwiftData")
            for character in characters {
                modelContext.insert(character)
            }
            try? modelContext.save()
        }
        
        return characters
    }
    
    func fetchLocations(page: Int = 1, modelContext: ModelContext? = nil) async throws -> [Location] {
        let query = """
        query {
          locations(page: \(page)) {
            info {
              count
              pages
              next
              prev
            }
            results {
              id
              name
              type
              dimension
              residents {
                id
              }
              created
            }
          }
        }
        """
        
        struct Response: Decodable {
            let data: Data
            
            struct Data: Decodable {
                let locations: Locations
                
                struct Locations: Decodable {
                    let results: [Location]
                }
            }
        }
        
        do {
            let response: Response = try await performRequest(query: query, path: [])
            let locations = response.data.locations.results
            
            if let modelContext = modelContext, !locations.isEmpty {
                print("💾 Saving \(locations.count) locations to SwiftData")
                
                // Use a background context for saving
                await Task.detached {
                    let backgroundContext = ModelContext(modelContext.container)
                    
                    // Insert each location in the background context
                    for location in locations {
                        // Create a new instance in the background context
                        let backgroundLocation = Location(
                            id: location.id,
                            name: location.name,
                            type: location.type,
                            dimension: location.dimension,
                            residentIds: location.residentIdArray
                        )
                        backgroundContext.insert(backgroundLocation)
                    }
                    
                    // Save the background context
                    try? backgroundContext.save()
                    
                    // Merge changes back to the main context if needed
                    await MainActor.run {
                        try? modelContext.save()
                    }
                }.value
            }
            
            return locations
        } catch {
            print("❌ Failed to fetch locations: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchEpisodes(page: Int = 1, modelContext: ModelContext? = nil) async throws -> [Episode] {
        let query = """
        query {
          episodes(page: \(page)) {
            info {
              count
              pages
              next
              prev
            }
            results {
              id
              name
              air_date
              episode
              characters {
                id
              }
              created
            }
          }
        }
        """
        
        struct Response: Decodable {
            let data: Data
            
            struct Data: Decodable {
                let episodes: Episodes
                
                struct Episodes: Decodable {
                    let results: [Episode]
                }
            }
        }
        
        let response: Response = try await performRequest(query: query, path: [])
        let episodes = response.data.episodes.results
        
        // Print the first episode for debugging
        if let firstEpisode = episodes.first {
            print("📺 First episode: \(firstEpisode.name)")
        }
        
        if let modelContext = modelContext {
            print("💾 Saving \(episodes.count) episodes to SwiftData")
            for episode in episodes {
                modelContext.insert(episode)
            }
            try? modelContext.save()
        }
        
        return episodes
    }
    
    private func performRequest<T: Decodable>(query: String, path: [String] = []) async throws -> T {
        guard let url = URL(string: baseURL) else {
            print("❌ Invalid URL: \(baseURL)")
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = ["query": query]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("📡 Sending request to: \(url.absoluteString)")
        print("📝 Query: \(query)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Print raw response for debugging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 Raw response: \(jsonString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid HTTP response")
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ Request failed with status code: \(httpResponse.statusCode)")
            throw APIError.requestFailed
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        do {
            // First decode the entire response to check for GraphQL errors
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errors = json["errors"] as? [[String: Any]], !errors.isEmpty {
                print("❌ GraphQL errors: \(errors)")
                throw APIError.invalidResponse
            }
            
            // If no path is provided, decode the entire response
            if path.isEmpty {
                return try decoder.decode(T.self, from: data)
            }
            
            // Otherwise, navigate the path and decode the target object
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw APIError.invalidResponse
            }
            
            var current: Any? = json
            for key in path {
                if let dict = current as? [String: Any] {
                    current = dict[key]
                    print("  - Key '\(key)' found")
                } else {
                    throw APIError.invalidResponse
                }
            }
            
            guard let result = current,
                  let resultData = try? JSONSerialization.data(withJSONObject: result) else {
                throw APIError.invalidResponse
            }
            
            return try decoder.decode(T.self, from: resultData)
            
        } catch let error as DecodingError {
            print("❌ Decoding error: \(error)")
            switch error {
            case .dataCorrupted(let context):
                print("Data corrupted: \(context)")
                if let underlyingError = context.underlyingError as NSError? {
                    print("Underlying error: \(underlyingError.userInfo)")
                }
            case .keyNotFound(let key, let context):
                print("Key '\(key.stringValue)' not found in: \(context.codingPath)")
                print("Debug description: \(context.debugDescription)")
            case .typeMismatch(_, let context):
                print("Type mismatch: \(context.debugDescription)")
                print("Coding path: \(context.codingPath)")
            case .valueNotFound(_, let context):
                print("Value not found: \(context.debugDescription)")
                print("Coding path: \(context.codingPath)")
            @unknown default:
                print("Unknown decoding error")
            }
            throw APIError.decodingError
        } catch {
            print("❌ Error: \(error)")
            throw error
        }
    }
}
