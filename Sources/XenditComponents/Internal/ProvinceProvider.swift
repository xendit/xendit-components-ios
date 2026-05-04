// ProvinceProvider — single source of truth for province/state data.
// Returns nil for unsupported countries so callers can fall back to free-text input.
// To add a new country: (1) add its entry to Resources/Provinces.json,
// (2) add its code to `supportedCountryCodes` below — no other changes required.
import Foundation

enum ProvinceProvider {

    // MARK: - Configuration

    /// Country codes that have province data in Provinces.json.
    /// This is the only place to update when adding a new supported country.
    static let supportedCountryCodes: Set<String> = ["US", "CA", "GB"]

    // MARK: - Public API

    /// Returns the province list for `countryCode`, or `nil` when the country
    /// is not in `supportedCountryCodes` (caller should show a free-text field).
    static func provinces(for countryCode: String) -> [Province]? {
        let key = countryCode.uppercased()
        guard supportedCountryCodes.contains(key) else { return nil }
        return allProvinces()[key]
    }

    // MARK: - Private cache

    private static var _cache: [String: [Province]]?

    private static func allProvinces() -> [String: [Province]] {
        if let cache = _cache { return cache }
        guard
            let url = Bundle.module.url(forResource: "Provinces", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode([String: [Province]].self, from: data)
        else {
            _cache = [:]
            return [:]
        }
        _cache = decoded
        return decoded
    }
}
