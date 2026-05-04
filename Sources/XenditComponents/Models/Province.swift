// Province — data model representing a single state/province option for a given country.
// Matches the shape of each entry in Resources/Provinces.json.
import Foundation

struct Province: Codable, Equatable {
    let code: String
    let name: String
}
