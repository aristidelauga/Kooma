

import Foundation
import CoreLocation
@preconcurrency import MapKit

final class GetRestaurantService: GetRestaurantInterface {

	func getCoordinate(from address: String) async throws -> CLLocationCoordinate2D {
		return try await withCheckedContinuation { continuation in
			CLGeocoder().geocodeAddressString(address) { placemarks, error in
				if let coordinate = placemarks?.first?.location?.coordinate {
					continuation.resume(returning: coordinate)
				} else {
					continuation.resume(throwing: error! as! Never)
				}
			}
		}
	}


	func searchNearbyRestaurants(
		at coordinate: CLLocationCoordinate2D,
		radiusInMeters: Double
	) async throws -> [MKMapItem] {
		let request = MKLocalSearch.Request()
		request.naturalLanguageQuery = "Restaurant"
		request.region = MKCoordinateRegion(
			center: coordinate,
			latitudinalMeters: radiusInMeters,
			longitudinalMeters: radiusInMeters
		)

		let search = MKLocalSearch(request: request)
		let response = try await search.start()
		return response.mapItems
	}
}
