
import Foundation
import FirebaseCore
import Firebase
import FirebaseFirestore

@MainActor
protocol FirestoreServiceInterface {
    var myRooms: [RoomUI] { get }
    var joinedRooms: [RoomUI] { get }
    
    func createRoom(_ room: RoomUI) async throws
    func joinRoom(withCode code: String, user: UserUI) async throws
    func fetchMyRooms(withUserID userID: String) async throws
    func fetchJoinedRooms(withUserID userID: String) async throws
}

@Observable
final class FirestoreService: FirestoreServiceInterface {
    
    private(set) var myRooms: [RoomUI] = []
    private(set) var joinedRooms: [RoomUI] = []
    
	private let client: any FirestoreClientInterface

	init(client: FirestoreClientInterface = FirestoreClient()) {
		self.client = client
	}

    
    func createRoom(_ room: RoomUI) async throws {
        let newRoom = RoomUI(
            id: nil,
            name: room.name,
            administrator: room.administrator,
            address: room.address,
            members: [room.administrator],
            restaurants: room.restaurants ?? []
        )
        
        do {
            _ = try await client.saveRoom(newRoom)
            try await fetchMyRooms(withUserID: room.administrator.id)
        } catch {
            throw NSError(domain: "RoomUI", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failure in the Service during an attempt of saving a room"])
        }
    }
    
    func joinRoom(withCode code: String, user: UserUI) async throws {
//        Task {
            do {
                try await self.client.joinRoom(withCode: code, user: user)
            } catch {
                throw NSError(domain: "RoomUI", code: 141, userInfo: [NSLocalizedDescriptionKey: "Failure in the Service during an attempt of joining a room"])
            }
            do {
                try await self.fetchJoinedRooms(withUserID: user.id)
            } catch {
                throw NSError(domain: "RoomUI", code: 121, userInfo: [NSLocalizedDescriptionKey: "Failure in the Service during an attempt of fetching joined rooms"])
            }
//        }
    }
    
    func fetchMyRooms(withUserID userID: String) async throws {
        self.myRooms = try await client.getMyRooms(forUserID: userID)
    }
    
    func fetchJoinedRooms(withUserID userID: String) async throws {
        self.joinedRooms = try await client.getJoinedRooms(forUserID: userID)
        print("self.joinedRooms.count: \(self.joinedRooms.count)")
    }
}

