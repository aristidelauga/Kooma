

import Foundation
import CoreLocation
@preconcurrency import MapKit

final class GetRestaurantService: GetRestaurantInterface {

	func getCoordinate(from address: String) async throws -> CLLocationCoordinate2D {
		return try await withCheckedThrowingContinuation { continuation in
			CLGeocoder().geocodeAddressString(address) { placemarks, error in
				if let coordinate = placemarks?.first?.location?.coordinate {
					continuation.resume(returning: coordinate)
				} else {
					continuation.resume(throwing: NSError(domain: "GeocodingError", code: 0))
				}
			}
		}
	}

	func searchNearbyRestaurants(
		at coordinate: CLLocationCoordinate2D,
		radiusInMeters: Double
	) async throws -> [RestaurantDTO]? {
		let request = MKLocalSearch.Request()
		request.naturalLanguageQuery = "Restaurant"
		request.region = MKCoordinateRegion(
			center: coordinate,
			latitudinalMeters: radiusInMeters,
			longitudinalMeters: radiusInMeters
		)

		let search = MKLocalSearch(request: request)
		let response = try await search.start()
		let restaurants: [RestaurantDTO]? = try response.mapItems.map { try self.toDTO(from: $0) ?? RestaurantDTO.emptyElement }
		return restaurants
	}
}

extension GetRestaurantService: DTORestaurantServiceConvertible {
	func toDTO(from item: MKMapItem?) throws -> RestaurantDTO? {
		guard
			let item,
			let identifier = item.identifier?.rawValue,
			let name = item.name,
			let phoneNumber = item.phoneNumber,
			let url = item.url?.absoluteString
		else {
			return nil
		}
		return RestaurantDTO(
			id: identifier,
			name: name,
			phoneNumber: phoneNumber,
			placemark: .init(from: item.placemark),
			url: url
		)
	}
}
