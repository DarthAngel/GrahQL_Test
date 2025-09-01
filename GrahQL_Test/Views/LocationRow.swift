//
// LocationRow.swift
//  GrahQL_Test
//
//  Created by Angel Docampo on 31/8/25.
//

import SwiftUI
import SwiftData

struct LocationRow: View {
    let location: Location
    
    private var residentCount: Int {
        (location.residentIds as? [String])?.count ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(location.name)
                .font(.headline)
            
            HStack {
                Text(location.type)
                Text("•")
                Text(location.dimension)
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            
            if residentCount > 0 {
                Text("\(residentCount) residents")
                    .font(.caption)
                    .foregroundColor(.blue)
            } else {
                Text("No residents")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let location = Location(
        id: "1",
        name: "Earth (C-137)",
        type: "Planet",
        dimension: "Dimension C-137",
        residentIds: ["1", "2", "3"]
    )
    return LocationRow(location: location)
        .modelContainer(for: Location.self, inMemory: true)
}
