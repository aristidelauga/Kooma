
import Foundation
import FirebaseCore
import Firebase


final class FirestoreRepository: FirestoreRepositoryInterface {

	private let client: any FirestoreClientInterface

	init(client: FirestoreClientInterface = FirestoreClient()) {
		self.client = client
	}

	func createRoom(_ room: RoomDTO) async throws {
		client.saveRoom(withName: <#T##String#>, aandRoom: <#T##RoomDTO#>)
	}
	

}

