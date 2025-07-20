
import Foundation

@Observable @MainActor
final class RoomDetailsViewModel {
    private let service: any FirestoreServiceInterface
    
    var myRooms: [RoomUI] = []
    var joinedRooms: [RoomUI] = []
    var currentRoom: RoomUI
    
    init(service: any FirestoreServiceInterface = FirestoreService(), currentRoom: RoomUI) {
        self.service = service
        self.currentRoom = currentRoom
    }
    
    private func updateCurrentRoom(with id: String) {
        if let room = (myRooms + joinedRooms).first(where: { $0.id == id }) {
            print("room.votes in updateCurrentRoom: \(room.votes)")
            self.currentRoom = room
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
    
    private func findRoom(_ room: RoomUI, from rooms: [RoomUI], userID: String) async throws -> RoomUI {
        guard let roomID = room.id,
              let room = try await self.service.getRoomByID(roomID, userID: userID)?.toUI() else {
            return  RoomUI(administrator: UserUI(id: "", name: ""))
        }
        return room
    }
    
    func vote(forRestaurant restaurant: RestaurantUI, inRoom room: RoomUI, user: UserUI) async throws {
        guard !hasVoted(forRestaurant: restaurant, user: user) else {
            return
        }

        var votes = self.currentRoom.votes
        let userVotes = votes.values.flatMap { $0 }.filter { $0 == user.id }.count
        guard userVotes < 2 else {
            return
        }

        var voters = votes[restaurant.id] ?? []
        
        voters.append(user.id)
        votes[restaurant.id] = voters
        self.currentRoom.votes = votes
        guard let roomID = currentRoom.id else {
            return
        }
        try await service.vote(forRoomID: roomID, votes: votes)
    }
    
    func removeVote() {
        
    }
    
    func getMyRoomsConverted(userID: String) async throws {
        try await self.service.fetchMyRooms(withUserID: userID)
        self.myRooms = self.service.myRooms.map { $0.toUI() }
    }
    
    func getJoinedRoomsConverted(userID: String) async throws {
        try await self.service.fetchJoinedRooms(withUserID: userID)
        self.joinedRooms = self.service.joinedRooms.map { $0.toUI() }
    }
    
    func beginListening(forUserID userID: String) {
        self.service.startListening(forUserID: userID)
        self.myRooms = self.service.myRooms.map { $0.toUI() }
        self.joinedRooms =  self.service.joinedRooms.map { $0.toUI() }
        if let id = self.currentRoom.id {
            self.updateCurrentRoom(with: id)
        }
    }
    
    func endListening() {
        self.service.stopListening()
    }
}
