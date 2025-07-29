
import Foundation
import MapKit

class MockRestaurantAPI: GetRestaurantInterface {
    
    var coordinateToReturn: CLLocationCoordinate2D?
    var coordinateError: Error?
    var searchResults: [RestaurantDTO]?
    var searchError: Error?

    func getCoordinate(from address: String) async throws -> CLLocationCoordinate2D {
        if let error = coordinateError { throw error }
        if let coord = coordinateToReturn { return coord }
        throw NSError(domain: "Mock", code: 1)
    }

    func searchNearbyRestaurants(at coordinate: CLLocationCoordinate2D, radiusInMeters: Double) async throws -> [RestaurantDTO]? {
        if let error = searchError { throw error }
        return searchResults
    }
}
