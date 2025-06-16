
import MapKit
import Foundation

@MainActor
@Observable final class RadiusSettingViewModel: Sendable {
	var address: String
	var region = MKCoordinateRegion()
	var items: [MKMapItem] = []
	private let restaurantAPI: any GetRestaurantInterface

	init(restaurantAPI: any GetRestaurantInterface = GetRestaurantService(), address: String) {
		self.restaurantAPI = restaurantAPI
		self.address = address
	}

	func searchRestaurants(within radius: Double) async {
		do {
			let coordinate = try await self.restaurantAPI.getCoordinate(from: address)
			region.center = coordinate
			let items = try await self.restaurantAPI.searchNearbyRestaurants(at: coordinate, radiusInMeters: radius * 1000)
			self.items = items
			for item in self.items {
				print("\(item) \n")
			}
		} catch {
			print("error during catching coordinate: \(error)")
		}
	}
}
