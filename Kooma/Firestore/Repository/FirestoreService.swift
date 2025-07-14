
import Foundation
import FirebaseCore
import Firebase
import FirebaseFirestore

@MainActor
protocol FirestoreServiceInterface {
    var rooms: [RoomUI] { get }
    func createRoom(_ room: RoomUI) async throws
    func fetchRooms(withUserID userID: String) async throws
//    func listenToRoom(id: String, onChange: @escaping (RoomDTO?) -> Void) -> ListenerRegistration
}

@Observable
final class FirestoreService: FirestoreServiceInterface {
    
    private(set) var rooms: [RoomUI] = []
    
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
            members: room.members ?? [room.administrator],
            restaurants: room.restaurants ?? []
        )
        
        do {
            _ = try await client.saveRoom(newRoom)
            // TODO: To be changed to Fetch**MY**Rooms as this would fetch only the rooms of the administrator
            try await fetchRooms(withUserID: room.administrator.id)
            // TODO: Add a second method to fetch the other rooms: fetchJoinedRooms()
        } catch {
            throw NSError(domain: "RoomUI", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failure in the Service during an attempt of saving a room"])
        }
    }
    
    func fetchRooms(withUserID userID: String) async throws {
        self.rooms = try await client.getRooms(forUserID: userID)
    }

}

