
import Foundation
import FirebaseCore
import Firebase

final class FirestoreClient: FirestoreClientInterface {
	var database: Firestore = Firestore.firestore()

	func saveRoom(_ room: RoomDTO) async throws -> String {
        let roomCollectionRef = database.collection("rooms")

		do {
			let documentRef = try roomCollectionRef.addDocument(from: room)
			return documentRef.documentID
		} catch {
			throw error
		}
	}
}
