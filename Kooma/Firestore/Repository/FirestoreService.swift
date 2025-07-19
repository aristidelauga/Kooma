
import Foundation
import FirebaseCore
import Firebase
import FirebaseFirestore

@MainActor
protocol FirestoreServiceInterface {
    var myRooms: [RoomDomain] { get }
    var joinedRooms: [RoomDomain] { get }
    
    func createRoom(_ room: RoomUI) async throws
    func joinRoom(withCode code: String, user: UserUI) async throws
    func fetchMyRooms(withUserID userID: String) async throws
    func fetchJoinedRooms(withUserID userID: String) async throws
    func updateVote(forRoomID roomID: String, votes: [String: [String]]) async throws
}

@Observable
final class FirestoreService: FirestoreServiceInterface {
    
    private(set) var myRooms: [RoomDomain] = []
    private(set) var joinedRooms: [RoomDomain] = []
    
	private let client: any FirestoreClientInterface

	init(client: FirestoreClientInterface = FirestoreClient()) {
		self.client = client
	}

    
    func createRoom(_ room: RoomUI) async throws {
        guard let address = room.address else {
            return
        }
        
            let newRoom = RoomDomain(
                id: room.id,
                code: room.code,
                name: room.name,
                administrator: try room.administrator.toDomain(),
                address: address,
                members: try room.members.map { try $0.toDomain() },
                regularMembersID: room.regularMembersID,
                restaurants: try room.restaurants.map { try $0.toDomain() },
                votes: room.votes,
                image: room.image
            )

        do {
            try await client.saveRoom(newRoom)
            try await fetchMyRooms(withUserID: room.administrator.id)
        } catch {
            throw NSError(domain: "RoomUI", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failure in the Service during an attempt of saving a room"])
        }
    }
    
    func joinRoom(withCode code: String, user: UserUI) async throws {
            do {
                try await self.client.joinRoom(withCode: code, user: user.toDomain())
            } catch {
                throw NSError(domain: "RoomUI", code: 141, userInfo: [NSLocalizedDescriptionKey: "Failure in the Service during an attempt of joining a room"])
            }
            do {
                try await self.fetchJoinedRooms(withUserID: user.id)
            } catch {
                throw NSError(domain: "RoomUI", code: 121, userInfo: [NSLocalizedDescriptionKey: "Failure in the Service during an attempt of fetching joined rooms"])
            }
    }
    
    func fetchMyRooms(withUserID userID: String) async throws {
        self.myRooms = try await client.getMyRooms(forUserID: userID)
    }
    
    func fetchJoinedRooms(withUserID userID: String) async throws {
        self.joinedRooms = try await client.getJoinedRooms(forUserID: userID)
        print("self.joinedRooms.count: \(self.joinedRooms.count)")
    }
    
    func updateVote(forRoomID roomID: String, votes: [String : [String]]) async throws {
        try await self.client.updateVotes(forRoomID: roomID, votes: votes)
    }
    
    func getRoomByID(_ roomID: String, userID: String) -> RoomDomain? {
        if let room = self.myRooms.first(where: { $0.id == roomID && $0.administrator.id == userID}) {
            return room
        } else if let room = self.joinedRooms.first(where: { $0.id == roomID }) {
            return room
        }
        return nil
    }
}

