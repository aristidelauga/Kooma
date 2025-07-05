
import Foundation
import FirebaseCore
import Firebase
import FirebaseFirestore

@MainActor
protocol FirestoreServiceInterface {
    func createRoom(_ room: RoomDTO) async throws -> String
    func fetchRooms() async throws -> [RoomDTO]
//    func listenToRoom(id: String, onChange: @escaping (RoomDTO?) -> Void) -> ListenerRegistration
}

final class FirestoreService: FirestoreServiceInterface {
    
	private let client: any FirestoreClientInterface

	init(client: FirestoreClientInterface = FirestoreClient()) {
		self.client = client
	}

    func createRoom(_ room: RoomDTO) async throws -> String {
        return try await self.client.saveRoom(room)
    }
    
    func fetchRooms() async throws -> [RoomDTO] {
        return try await self.client.fetchRooms()
    }

}

