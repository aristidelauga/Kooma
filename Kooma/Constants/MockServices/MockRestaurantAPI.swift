
import Foundation
import MapKit

class MockRestaurantAPI: GetRestaurantInterface {
    
    var coordinateToReturn: CLLocationCoordinate2D?
    var coordinateError: Error?
    var searchResults: [RestaurantDTO]?
    var searchError: Error?

    /// Used for testing purposes to mimick the behavior of `getCoordinate` of `GetRestaurantService`
    func getCoordinate(from address: String) async throws -> CLLocationCoordinate2D {
        if let error = coordinateError { throw error }
        if let coord = coordinateToReturn { return coord }
        throw NSError(domain: "Mock", code: 1)
    }

    /// Used for testing purposes to mimick the behavior of `searchNearbyRestaurants` of `GetRestaurantService`
    func searchNearbyRestaurants(at coordinate: CLLocationCoordinate2D, radiusInMeters: Double) async throws -> [RestaurantDTO]? {
        if let error = searchError { throw error }
        return searchResults
    }
}
