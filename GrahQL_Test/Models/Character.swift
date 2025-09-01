//
//  Character.swift
//  GrahQL_Test
//
//  Created by Angel Docampo on 29/8/25.
//

import Foundation
import SwiftData

@Model
final class Character: Identifiable, Codable {
    @Attribute(.unique) var id: String
    var name: String
    var status: String
    var species: String
    var type: String
    var gender: String
    var image: String
    var created: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, status, species, type, gender, image, created
    }
    
    init(id: String, name: String, status: String, species: String, type: String, gender: String, image: String, created: String) {
        self.id = id
        self.name = name
        self.status = status
        self.species = species
        self.type = type
        self.gender = gender
        self.image = image
        self.created = created
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
        status = try container.decode(String.self, forKey: .status)
        species = try container.decode(String.self, forKey: .species)
        type = try container.decode(String.self, forKey: .type)
        gender = try container.decode(String.self, forKey: .gender)
        image = try container.decode(String.self, forKey: .image)
        created = try container.decode(String.self, forKey: .created)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(status, forKey: .status)
        try container.encode(species, forKey: .species)
        try container.encode(type, forKey: .type)
        try container.encode(gender, forKey: .gender)
        try container.encode(image, forKey: .image)
        try container.encode(created, forKey: .created)
    }
}
