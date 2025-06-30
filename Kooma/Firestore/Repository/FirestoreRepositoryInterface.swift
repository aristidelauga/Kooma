
import Foundation
import FirebaseCore
import Firebase


@MainActor
protocol FirestoreRepositoryInterface {
	func createRoom(_ room: RoomDTO) async throws
//	func getRoom(byId id: String) async throws -> RoomDTO
//	func listenToRoom(id: String, onChange: @escaping (RoomDTO?) -> Void) -> ListenerRegistration
}

