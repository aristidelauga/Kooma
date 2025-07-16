
import Foundation

@Observable @MainActor
final class RoomDetailsViewModel {
    private let service: any FirestoreServiceInterface
    
    var myRooms: [RoomUI] { service.myRooms }
    var joinedRooms: [RoomUI] { service.joinedRooms }
    
    init(service: any FirestoreServiceInterface = FirestoreService()) {
        self.service = service
    }
    
    func hasVoted(forRestaurant restaurant: RestaurantUI, in room: RoomUI, user: UserUI) -> Bool {
        room.votes[restaurant.id]?.contains(user.id) ?? false
    }
    
    private func findRoom(_ room: RoomUI, from rooms: [RoomUI]) -> RoomUI {
        guard let room = rooms.first(where: { $0.id == room.id }) else {
            return RoomUI(administrator: UserUI(id: "", name: ""))
        }
        return room
    }
    
    func vote(forRestaurant restaurant: RestaurantUI, inRoom room: RoomUI, user: UserUI) async throws {
        let isAdmin = user.id == room.administrator.id
        
        var roomtoVote = RoomUI(id: nil, name: "", administrator: UserUI(id: "", name: ""))
        
        if isAdmin {
            roomtoVote = self.findRoom(room, from: self.myRooms)
        } else {
            roomtoVote = self.findRoom(room, from: self.joinedRooms)
        }
        
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
        try await service.updateVote(forRoomID: roomID, votes: votes)
        print("votes: \(roomtoVote.votes)")
        for vote in roomtoVote.votes.keys {
            print("room's vote: \(vote)")
        }
        print("userID: \(user.id)")
        if let index = roomtoVote.restaurants.firstIndex(where: { $0.id == restaurant.id }) {
               roomtoVote.restaurants[index].vote += 1
           }
        
        if isAdmin {
            try await self.service.fetchMyRooms(withUserID: user.id)
        } else {
            try await self.service.fetchJoinedRooms(withUserID: user.id)
        }
    }
    
    func removeVote() {
        
    }
    
    
}
