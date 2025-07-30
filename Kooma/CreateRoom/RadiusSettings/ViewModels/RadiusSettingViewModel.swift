
import MapKit
import Foundation

@MainActor
@Observable final class RadiusSettingViewModel {
    var region = MKCoordinateRegion()
    var room: RoomUI
    var isLoading = false
    
    var restaurantsDTO: [RestaurantDTO] = []
    
    private let restaurantAPI: any GetRestaurantInterface
    private let service: any FirestoreServiceInterface
    
    
    init(
        restaurantAPI: any GetRestaurantInterface = GetRestaurantService(),
        service: any FirestoreServiceInterface = FirestoreService(),
        room: RoomUI
    ) {
        self.restaurantAPI = restaurantAPI
        self.service = service
        self.room = room
    }
    
    /// Uses the RestaurantService to find restaurants around the room's address
    /// using the given radius
    /// `Radius * 1000` being used to calculate the radius in kilometers
    func searchRestaurants(within radius: Double) async throws {
        guard let address = self.room.address, !address.isEmpty else {
            throw NSError(domain: "RoomUI", code: 4, userInfo: [NSLocalizedDescriptionKey: "Address is missing. Please enter a valid address"])
        }
        self.isLoading = true
        defer { self.isLoading = false }
        do {
            let coordinate = try await self.restaurantAPI.getCoordinate(from: address)
            region.center = coordinate
            guard let items = try await self.restaurantAPI.searchNearbyRestaurants(at: coordinate, radiusInMeters: radius * 1000) else {
                return
            }
            let itemsUI = try items.compactMap { try $0.toUI() }
            self.room.restaurants = itemsUI
        } catch {
            throw NSError(domain: "RoomUI", code: 14, userInfo: [NSLocalizedDescriptionKey: "Restaurants fetching attempt failed."])
        }
        
        ActionEvent.sendAnalytics(event: .createdNewRoomSuccessfully)
    }
    
    /// Adds the new created room to Firestore
    func addNewRoom(_ room: RoomUI) async throws {
        try await self.service.createRoom(room)
    }
    
}
