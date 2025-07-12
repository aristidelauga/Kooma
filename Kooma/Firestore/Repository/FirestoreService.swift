
import Foundation
import FirebaseCore
import Firebase
import FirebaseFirestore

@MainActor
protocol FirestoreServiceInterface {
    var rooms: [RoomUI] { get }
    func createRoom(_ room: RoomUI) async throws
    func fetchRooms() async throws
//    func listenToRoom(id: String, onChange: @escaping (RoomDTO?) -> Void) -> ListenerRegistration
}

@Observable
final class FirestoreService: FirestoreServiceInterface {
    
    private(set) var rooms: [RoomUI] = []
    
	private let client: any FirestoreClientInterface

	init(client: FirestoreClientInterface = FirestoreClient()) {
		self.client = client
//        Task { @MainActor in
//            try await self.fetchRooms()
//            print("self.service.rooms.isEmpty' in FirestoreService: \(self.rooms.isEmpty)")
//            try await Task.sleep(for: .seconds(3)) 
//        }
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
            try await fetchRooms()
        } catch {
            throw NSError(domain: "RoomUI", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failure in the Service during an attempt of saving a room"])
        }
    }
    
    func fetchRooms() async throws {
        self.rooms = try await client.getRooms()
    }

}

