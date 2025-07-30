
import Foundation

@Observable @MainActor
final class RoomDetailsViewModel {
    private let service: any FirestoreServiceInterface
    
    var myRooms: [RoomUI] = []
    var joinedRooms: [RoomUI] = []
    var currentRoom: RoomUI
    var roomWasDeleted = false
    
    private var currentRoomObservationTask: Task<Void, Never>?
    
    init(service: any FirestoreServiceInterface = FirestoreService(), currentRoom: RoomUI) {
        self.service = service
        self.currentRoom = currentRoom
        
        if let id = currentRoom.id {
            setupCurrentRoomObservation(roomID: id)
        }
    }
    
    /// Listens to any modifications made in the room matching the `currentRoom`'s ID
    /// So it updates the `currentRoom` in real-time
    private func setupCurrentRoomObservation(roomID: String) {
        currentRoomObservationTask?.cancel()
        
        currentRoomObservationTask = Task {
            do {
                for try await result in service.roomStream(withID: roomID) {
                    self.currentRoom = result.toUI()
                }
                self.roomWasDeleted = false
            } catch {
                print("Error listening to room \(roomID): \(error)")
                self.roomWasDeleted = true
            }
        }
    }
    
    /// Returns a boolean asserting whether a user has voted for a given restaurant
    func hasVoted(forRestaurant restaurant: RestaurantUI, user: UserUI) -> Bool {
        self.currentRoom.votes[restaurant.id]?.contains(user.id) ?? false
    }
    
    /// Returns the amounf of vote for a given restaurant
    func getVoteCount(withRestaurantID id: String) -> Int {
        guard let restaurantVotes = self.currentRoom.votes[id] else {
            return 0
        }
        return restaurantVotes.count
    }
    
    /// Vote for a given restaurant with a given user ID
    /// Checks if the user has already voted for two restaurants or not
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
    
    /// Removes vote of a given user for a given restaurant
    /// Checks if the user did really voted for this restaurant or not
    /// If he did, terminates the method
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
    
    /// Allows the user to leave a room
    func leaveRoom(user: UserUI) async throws {
        guard let id = self.currentRoom.id else {
            return
        }
        try await self.service.leaveRoom(roomID: id, user: user)
    }
    
    /// Allows the administrator of a room to delete it
    func deleteRoom(user: UserUI) async throws {
        guard let id = self.currentRoom.id else {
            return
        }
        try await self.service.deleteRoom(withID: id, byuserID: user.id)
        self.roomWasDeleted = true
    }
    
    
    /// Fetches all the users' names who voted for a given restaurant
    /// So we can transfer these names to `RestaurantDetailView`
    func getVotersNames(for restaurantID: String) -> [String] {
        
        let votersID = self.currentRoom.votes[restaurantID] ?? []
        
        let names = self.currentRoom.members
            .filter { votersID.contains($0.id) }
            .map { $0.name }
        
        return names
    }
}
