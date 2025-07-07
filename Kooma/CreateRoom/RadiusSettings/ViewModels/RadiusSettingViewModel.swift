
import MapKit
import Foundation

@MainActor
@Observable final class RadiusSettingViewModel {
	var region = MKCoordinateRegion()
	var room: RoomUI
	var isLoading = false
    var rooms: [RoomUI] {
        self.service.rooms
    }
    var restaurantsDTO: [RestaurantDTO] = []
//    var errorMessage: String?

	private let restaurantAPI: any GetRestaurantInterface
    private let service: FirestoreServiceInterface


    init(
        restaurantAPI: any GetRestaurantInterface = GetRestaurantService(),
        service: FirestoreServiceInterface = FirestoreService(),
        room: RoomUI
    ) {
		self.restaurantAPI = restaurantAPI
        self.service = service
        self.room = room
	}

	func searchRestaurants(within radius: Double) async throws {
		guard let address = self.room.address, !address.isEmpty else {
//            self.errorMessage = "Address is missing. Please enter a valid address"
            throw NSError(domain: "RoomUI", code: 4, userInfo: [NSLocalizedDescriptionKey: "Address is missing. Please enter a valid address"])
        }
		self.isLoading = true
//        self.errorMessage = nil
		defer { self.isLoading = false }
//		do {
			let coordinate = try await self.restaurantAPI.getCoordinate(from: address)
			region.center = coordinate
			guard let items = try await self.restaurantAPI.searchNearbyRestaurants(at: coordinate, radiusInMeters: radius * 1000) else { return }
        self.restaurantsDTO = items
			let itemsUI = try items.map { try $0.toUI() }
			self.room.restaurants = itemsUI
//		} catch {
//            self.errorMessage = "Could not find the address. Please check it and try again."
//			print("error during catching coordinate: \(error)")
//		}
	}
    
    func addNewRoom(_ room: RoomUI) async throws {
        //        do {
        var roomDTO = try await room.toDTO()
        roomDTO.restaurants = restaurantsDTO
        print("RoomDTO: \(roomDTO)")
        try await self.service.createRoom(roomDTO)
        print("rooms's count: \(rooms.count)")
        //        } catch {
        //            self.errorMessage = "Could not find the address. Please check it and try again."
        //            throw NSError(domain: "RoomUI", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failure in the Service during an attempt of saving a room"])
        //        }
    }
}
