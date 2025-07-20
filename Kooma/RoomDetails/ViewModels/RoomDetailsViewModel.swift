
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
    
    func hasVoted(forRestaurant restaurant: RestaurantUI, in room: RoomUI, user: UserUI) -> Bool {
        room.votes[restaurant.id]?.contains(user.id) ?? false
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
        let isAdmin = user.id == room.administrator.id
        
        var roomtoVote = RoomUI(id: nil, name: "", administrator: UserUI(id: "", name: ""))
        
//        if isAdmin {
//            roomtoVote = try await self.findRoom(room, from: self.myRooms, userID: user.id)
//        } else {
//            roomtoVote = try await self.findRoom(room, from: self.joinedRooms, userID: user.id)
//        }
        
        guard !hasVoted(forRestaurant: restaurant, in: roomtoVote, user: user), let roomID = room.id else {
            return
        }

        var votes = roomtoVote.votes
        let userVotes = votes.values.flatMap { $0 }.filter { $0 == user.id }.count
        guard userVotes < 2 else {
            return
        }

        var voters = votes[restaurant.id] ?? []
        
        voters.append(user.id)
        votes[restaurant.id] = voters
        try await service.vote(forRoomID: roomID, votes: votes)
//        if let index = roomtoVote.restaurants.firstIndex(where: { $0.id == restaurant.id }) {
//               roomtoVote.restaurants[index].vote += 1
//           }
        
        if isAdmin {
            try await self.service.fetchMyRooms(withUserID: user.id)
        } else {
            try await self.service.fetchJoinedRooms(withUserID: user.id)
        }
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
