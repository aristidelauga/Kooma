
import Foundation

@Observable @MainActor
final class RoomDetailsViewModel {
    private let service: any FirestoreServiceInterface
    
    var joinedRooms: [RoomUI] { service.joinedRooms }
    
    init(service: any FirestoreServiceInterface = FirestoreService()) {
        self.service = service
    }
    
    func vote(_ room: RoomUI, user: UserUI, forRestaurant restaurant: RestaurantUI) {
        let room = self.joinedRooms.first(where: { $0.id == room.id })
        var user = room?.members.first(where: { $0.id == user.id })
        var restaurant = room?.restaurants.first(where: { $0.id == restaurant.id })
        
//        guard userr
    }
}
