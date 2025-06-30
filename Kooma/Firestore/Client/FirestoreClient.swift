
import Foundation
import FirebaseCore
import Firebase

final class FirestoreClient: FirestoreClientInterface {
	var database: Firestore = Firestore.firestore()

	func saveRoom(withName name: String, aandRoom room: RoomDTO) async throws -> String {
		let roomCollectionRef = database.collection(name)

		do {
			let documentRef = try roomCollectionRef.addDocument(from: room)
			return documentRef.documentID
		} catch {
			throw error
		}
	}
}
