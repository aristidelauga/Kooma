
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
    func leaveRoom(roomID: String, user: UserUI) async throws
    func deleteRoom(withID: String, byuserID userID: String) async throws
    
    func fetchMyRooms(withUserID userID: String) async throws
    func fetchJoinedRooms(withUserID userID: String) async throws
    
    func myRoomsStream(forUserID userID: String) -> AsyncThrowingStream<[RoomDomain], Error>
    func joinedRoomsStream(forUserID userID: String) -> AsyncThrowingStream<[RoomDomain], Error>
    func roomStream(withID roomID: String) -> AsyncThrowingStream<RoomDomain, Error>
    
    func addVote(forRoomID roomID: String, restaurantID: String, userID: String) async throws
    func removeVote(forRoomID roomID: String, restaurantID: String, userID: String) async throws

}

@Observable
final class FirestoreService: FirestoreServiceInterface {
    
    private(set) var myRooms: [RoomDomain] = []
    private(set) var joinedRooms: [RoomDomain] = []
    
    private var myRoomsTask: Task<Void, Never>?
    private var joinedRoomsTask: Task<Void, Never>?
    
	private let client: any FirestoreClientInterface

	init(client: FirestoreClientInterface = FirestoreClient()) {
		self.client = client
	}
    
    /// Allows a user to create a room
    func createRoom(_ room: RoomUI) async throws {
        guard let address = room.address, let image = room.image else {
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
                image: image
            )

        do {
            try await client.saveRoom(newRoom)
        } catch {
            throw NSError(domain: "RoomUI", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failure in the Service during an attempt of saving a room"])
        }
    }
    
    /// Allows a user to join a room
    func joinRoom(withCode code: String, user: UserUI) async throws {
            do {
                try await self.client.joinRoom(withCode: code, user: user.toDomain())
            } catch {
                throw NSError(domain: "RoomUI", code: 141, userInfo: [NSLocalizedDescriptionKey: "Failure in the Service during an attempt of joining a room"])
            }

    }
    
    /// Allows a user to leave a given room
    func leaveRoom(roomID: String, user: UserUI) async throws {
        let userDomain = UserDomain(id: user.id, name: user.name)
        try await self.client.leaveRoom(roomID: roomID, user: userDomain)
    }
    
    func deleteRoom(withID: String, byuserID userID: String) async throws {
        try await self.client.deleteRoom(withID: withID, byuserID: userID)
    }
    
    /// Used to get real-time update of user's created rooms
    func myRoomsStream(forUserID userID: String) -> AsyncThrowingStream<[RoomDomain], Error> {
        client.listenToMyRooms(forUserID: userID)
    }

    /// Used to get real-time update of user's joined roomse
    func joinedRoomsStream(forUserID userID: String) -> AsyncThrowingStream<[RoomDomain], Error> {
        client.listenToJoinedRooms(forUserID: userID)
    }

    /// Used to get real-time update of a given room
    func roomStream(withID roomID: String) -> AsyncThrowingStream<RoomDomain, Error> {
        client.listenToRoom(withID: roomID)
    }
    
    /// Used when the app get launched so we display the right screen to the user
    func fetchMyRooms(withUserID userID: String) async throws {
        self.myRooms = try await self.client.getMyRooms(forUserID: userID)
    }

    /// Used when the app get launched so we display the right screen to the user
    func fetchJoinedRooms(withUserID userID: String) async throws {
        self.joinedRooms = try await self.client.getJoinedRooms(forUserID: userID)
    }
    
    /// Allow a user to vote for a given restaurant within a given room
    func addVote(forRoomID roomID: String, restaurantID: String, userID: String) async throws {
        try await self.client.updateVotes(forRoomID: roomID, restaurantID: restaurantID, userID: userID, action: .add)
    }
    
    /// Allow a user to vote for a given restaurant within a given room
    func removeVote(forRoomID roomID: String, restaurantID: String, userID: String) async throws {
        try await self.client.updateVotes(forRoomID: roomID, restaurantID: restaurantID, userID: userID, action: .remove)
    }

}

