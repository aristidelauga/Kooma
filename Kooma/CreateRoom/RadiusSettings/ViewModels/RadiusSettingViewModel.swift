
import MapKit
import Foundation

@MainActor
@Observable final class RadiusSettingViewModel {
	var region = MKCoordinateRegion()
	var room: RoomUI
	var isLoading = false

	private let restaurantAPI: any GetRestaurantInterface

	init(restaurantAPI: any GetRestaurantInterface = GetRestaurantService(), room: RoomUI) {
		self.restaurantAPI = restaurantAPI
		self.room = room
	}

	func searchRestaurants(within radius: Double) async {
		guard let address = self.room.address else { return }
		self.isLoading = true
		defer { self.isLoading = false }
		do {
			let coordinate = try await self.restaurantAPI.getCoordinate(from: address)
			region.center = coordinate
			guard let items = try await self.restaurantAPI.searchNearbyRestaurants(at: coordinate, radiusInMeters: radius * 1000) else { return }
			let itemsUI = try items.map { try $0.toUI() }
			self.room.restaurants = itemsUI
		} catch {
			print("error during catching coordinate: \(error)")
		}
	}
}
