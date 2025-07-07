
import Foundation
import FirebaseCore
import Firebase
import FirebaseFirestore

@MainActor
protocol FirestoreServiceInterface {
    var rooms: [RoomUI] { get }
    func createRoom(_ room: RoomDTO) async throws
    func fetchRooms() async throws
//    func listenToRoom(id: String, onChange: @escaping (RoomDTO?) -> Void) -> ListenerRegistration
}

@Observable
final class FirestoreService: FirestoreServiceInterface {
    
    private(set) var rooms: [RoomUI] = []
    
	private let client: any FirestoreClientInterface

	init(client: FirestoreClientInterface = FirestoreClient()) {
		self.client = client
	}

    
    func createRoom(_ room: RoomDTO) async throws {
        print("createRoom being called.")
//        return try await self.client.saveRoom(room)
        let newRoomDTO = RoomDTO(
            id: nil,
            name: room.name,
            administrator: room.administrator,
            address: room.address,
            members: room.members,
            restaurants: room.restaurants
        )
        
//        do {
            _ = try await client.saveRoom(newRoomDTO)
            try await fetchRooms()
//        } catch {
//            throw NSError(domain: "RoomUI", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failure in the Service during an attempt of saving a room"])
//        }
    }
    
    func fetchRooms() async throws {
//        return try await self.client.fetchRooms()
//        do {
            let roomDTOs = try await client.getRooms()
            self.rooms = try roomDTOs.map { try $0.toUI() }
//        } catch {
            self.rooms = []
//            throw NSError(domain: "RoomUI", code: 2, userInfo: [NSLocalizedDescriptionKey: "No room to load"])
//        }
    }

}

