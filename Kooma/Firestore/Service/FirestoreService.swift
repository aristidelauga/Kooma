
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
    func vote(forRoomID roomID: String, votes: [String: [String]]) async throws
    func getRoomByID(_ roomID: String, userID: String) async throws -> RoomDomain?
    
    func startListening(forUserID userID: String)
    func stopListening()

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

    
    func createRoom(_ room: RoomUI) async throws {
        guard let address = room.address else {
            return
        }
        print("room.votes \(room.votes)")
        guard let image = room.image else {
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
    
    func joinRoom(withCode code: String, user: UserUI) async throws {
            do {
                try await self.client.joinRoom(withCode: code, user: user.toDomain())
            } catch {
                throw NSError(domain: "RoomUI", code: 141, userInfo: [NSLocalizedDescriptionKey: "Failure in the Service during an attempt of joining a room"])
            }

    }
    
    func fetchMyRooms(withUserID userID: String) async throws {
        self.myRooms = try await self.client.getMyRooms(forUserID: userID)
    }
    
    func fetchJoinedRooms(withUserID userID: String) async throws {
        self.joinedRooms = try await self.client.getJoinedRooms(forUserID: userID)
    }
    
    func vote(forRoomID roomID: String, votes: [String : [String]]) async throws {
        try await self.client.vote(forRoomID: roomID, votes: votes)
    }
    
    func getRoomByID(_ roomID: String, userID: String) async throws -> RoomDomain? {
        if let room = self.myRooms.first(where: { $0.id == roomID && $0.administrator.id == userID}) {
            return room
        } else if let room = self.joinedRooms.first(where: { $0.id == roomID }) {
            return room
        }
        return nil
    }
    
    func startListening(forUserID userID: String) {
        self.stopListening()
        
        myRoomsTask = Task {
            do {
                let stream = client.listenToMyRooms(forUserID: userID)
                for try await rooms in stream {
                    self.myRooms = rooms
                }
            } catch {
                print("Error listening to my rooms in FireStoreService: \(error.localizedDescription)")
            }
        }
        
        joinedRoomsTask = Task {
            do {
                let stream = client.listenToJoinedRooms(forUserID: userID)
                for try await rooms in stream {
                    self.joinedRooms = rooms
                }
            } catch {
                print("Error listening to joined rooms in FireStoreService: \(error.localizedDescription)")
            }
        }
    }
    
    func stopListening() {
        self.myRoomsTask?.cancel()
        self.joinedRoomsTask?.cancel()
        self.myRoomsTask = nil
        self.joinedRoomsTask = nil
    }

}

