

import Foundation
import CoreLocation
@preconcurrency import MapKit

@MainActor
protocol GetRestaurantInterface {
    func getCoordinate(from address: String) async throws -> CLLocationCoordinate2D
    func searchNearbyRestaurants(at coordinate: CLLocationCoordinate2D, radiusInMeters: Double) async throws -> [RestaurantDTO]?
    func searchMapItem(for restaurant: RestaurantUI) async -> MKMapItem?
}

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
    
    func searchMapItem(for restaurant: RestaurantUI) async -> MKMapItem? {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = restaurant.name
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: restaurant.placemark.latitude,
                                           longitude: restaurant.placemark.longitude),
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )

        let search = MKLocalSearch(request: request)

        do {
            let response = try await search.start()
            if let mapItem = response.mapItems.first {
               
                return mapItem
            }
        } catch {
            print("Error searching map item: \(error)")
        }

        return nil
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
		let restaurants: [RestaurantDTO]? = try response.mapItems.compactMap { try self.toDTO(from: $0) }
		return restaurants
	}
}

extension GetRestaurantService: DTORestaurantServiceConvertible {
	func toDTO(from item: MKMapItem?) throws -> RestaurantDTO? {
		if
			let item,
			let identifier = item.identifier?.rawValue,
			let name = item.name,
			let phoneNumber = item.phoneNumber,
            let url = item.url?.absoluteString {
            return RestaurantDTO(
                id: identifier,
                name: name,
                phoneNumber: phoneNumber,
                placemark: .init(from: item.placemark),
                url: url,
            )
        }
        return nil
	}
}
