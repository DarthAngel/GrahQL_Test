//  Location.swift
//  GrahQL_Test
//
//  Created by Angel Docampo on 29/8/25.
//

import Foundation
import SwiftData

@Model
final class Location: Identifiable, Codable {
    @Attribute(.unique) var id: String
    var name: String
    var type: String
    var dimension: String
    @Attribute(.transformable(by: StringArrayTransformer.self)) var residentIds: NSArray?
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, dimension
        case residentIds = "residents"
    }
    
    // Helper to convert between [String] and NSArray
    var residentIdArray: [String] {
        get {
            return (residentIds as? [String]) ?? []
        }
        set {
            residentIds = newValue.isEmpty ? nil : newValue as NSArray
        }
    }
    
    init(id: String, name: String, type: String, dimension: String, residentIds: [String] = []) {
        self.id = id
        self.name = name
        self.type = type
        self.dimension = dimension
        self.residentIds = residentIds.isEmpty ? nil : residentIds as NSArray
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
        type = try container.decode(String.self, forKey: .type)
        dimension = try container.decode(String.self, forKey: .dimension)
        // Handle resident IDs - they come as an array of character objects with id and name
        if let residents = try? container.decodeIfPresent([Resident].self, forKey: .residentIds) {
            let residentIdValues = residents.map { $0.id }
            residentIds = residentIdValues.isEmpty ? nil : residentIdValues as NSArray
        } else {
            residentIds = nil
        }
    }
    
    // Helper struct for decoding resident objects
    private struct Resident: Decodable {
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
                throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "Resident ID is not a String or Integer")
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(dimension, forKey: .dimension)
        
        // Encode residentIds as an array of URLs
        if !residentIdArray.isEmpty {
            let residentURLs = residentIdArray.map { "https://rickandmortyapi.com/api/character/\($0)" }
            try container.encode(residentURLs, forKey: .residentIds)
        }
    }
}
