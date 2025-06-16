
import CoreLocation
import Foundation
import MapKit

@MainActor
protocol GetRestaurantInterface {
	func getCoordinate(from address: String) async throws -> CLLocationCoordinate2D
	func searchNearbyRestaurants(at coordinate: CLLocationCoordinate2D, radiusInMeters: Double) async throws -> [MKMapItem]
}
