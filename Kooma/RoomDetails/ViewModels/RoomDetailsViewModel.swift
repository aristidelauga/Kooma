
import Foundation

@Observable @MainActor
final class RoomDetailsViewModel {
    private let service: any FirestoreServiceInterface
    
    var myRooms: [RoomUI] = []
    var joinedRooms: [RoomUI] = []
    var currentRoom: RoomUI
    
    private var currentRoomObservationTask: Task<Void, Never>?
    
    init(service: any FirestoreServiceInterface = FirestoreService(), currentRoom: RoomUI) {
        self.service = service
        self.currentRoom = currentRoom
        
        if let id = currentRoom.id {
            setupCurrentRoomObservation(roomID: id)
        }
    }

    private func setupCurrentRoomObservation(roomID: String) {
        currentRoomObservationTask?.cancel()
        
        currentRoomObservationTask = Task {
            do {
                for try await room in service.roomStream(withID: roomID) {
                    self.currentRoom = room.toUI()
                }
            } catch {
                print("Error listening to room \(roomID): \(error)")
            }
        }
    }
    
    func hasVoted(forRestaurant restaurant: RestaurantUI, user: UserUI) -> Bool {
        self.currentRoom.votes[restaurant.id]?.contains(user.id) ?? false
    }
    
    func getVoteCount(withRestaurantID id: String) -> Int {
        guard let restaurantVotes = self.currentRoom.votes[id] else {
            return 0
        }
        return restaurantVotes.count
    }
    
    func vote(forRestaurant restaurant: RestaurantUI, user: UserUI) async throws {
        guard !hasVoted(forRestaurant: restaurant, user: user) else {
            return
        }
        
        let votes = self.currentRoom.votes
        let userVotes = votes.values.flatMap { $0 }.filter { $0 == user.id }.count
        guard userVotes < 2 else {
            return
        }
        
        guard let roomID = currentRoom.id else {
            print("Error: Room ID is nil")
            return
        }
        
        try await self.service.addVote(forRoomID: roomID, restaurantID: restaurant.id, userID: user.id)
    }
    
    func removeVote(forRestaurant restaurant: RestaurantUI, user: UserUI) async throws {
        guard hasVoted(forRestaurant: restaurant, user: user) else {
            return
        }
        
        guard let roomID = currentRoom.id else {
            print("Error: Room ID is nil")
            return
        }
        
        try await service.removeVote(forRoomID: roomID, restaurantID: restaurant.id, userID: user.id)
    }
    
    func startListening(forUserID userID: String) {
        self.service.startListening(forUserID: userID)
    }
    
    func endListening() {
        self.service.stopListening()
        currentRoomObservationTask?.cancel()
    }
}
