//  Episode.swift
//  GrahQL_Test
//
//  Created by Angel Docampo on 29/8/25.
//

import Foundation
import SwiftData

@Model
final class Episode: Identifiable, Codable {
    @Attribute(.unique) var id: String
    var name: String
    var airDate: String = "Unknown"
    var episode: String
    @Attribute(.transformable(by: StringArrayTransformer.self)) var characterIds: NSArray?
    
    enum CodingKeys: String, CodingKey {
        case id, name, episode
        case airDate = "air_date"
        case characterIds = "characters"
    }
    
    // Helper to convert between [String] and NSArray
    var characterIdArray: [String] {
        get {
            return (characterIds as? [String]) ?? []
        }
        set {
            characterIds = newValue.isEmpty ? nil : newValue as NSArray
        }
    }
    
    init(id: String, name: String, airDate: String = "Unknown", episode: String, characterIds: [String] = []) {
        self.id = id
        self.name = name
        self.airDate = airDate
        self.episode = episode
        self.characterIds = characterIds.isEmpty ? nil : characterIds as NSArray
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle both String and Int IDs
        if let stringId = try? container.decode(String.self, forKey: .id) {
            id = stringId
        } else if let intId = try? container.decode(Int.self, forKey: .id) {
            id = String(intId)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "ID is not a String or Integer")
        }
        
        name = try container.decode(String.self, forKey: .name)
        airDate = try container.decodeIfPresent(String.self, forKey: .airDate) ?? "Unknown"
        episode = try container.decode(String.self, forKey: .episode)
        
        // Handle character IDs - they come as an array of character objects with id and name
        if let characters = try? container.decodeIfPresent([CharacterRef].self, forKey: .characterIds) {
            let characterIdValues = characters.map { $0.id }
            characterIds = characterIdValues.isEmpty ? nil : characterIdValues as NSArray
        } else {
            characterIds = nil
        }
    }
    
    // Helper struct for decoding character references
    private struct CharacterRef: Decodable {
        let id: String
        
        enum CodingKeys: String, CodingKey {
            case id
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            // Handle both String and Int IDs
            if let stringId = try? container.decode(String.self, forKey: .id) {
                id = stringId
            } else if let intId = try? container.decode(Int.self, forKey: .id) {
                id = String(intId)
            } else {
                throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "Character ID is not a String or Integer")
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(airDate, forKey: .airDate)
        try container.encode(episode, forKey: .episode)
        
        // Encode characterIds as an array of URLs
        if !characterIdArray.isEmpty {
            let characterURLs = characterIdArray.map { "https://rickandmortyapi.com/api/character/\($0)" }
            try container.encode(characterURLs, forKey: .characterIds)
        }
    }
}
