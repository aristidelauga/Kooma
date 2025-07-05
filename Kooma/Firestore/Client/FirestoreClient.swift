
import Foundation
import FirebaseCore
import Firebase
import FirebaseFirestore

private enum FirestoreConstants {
    static let roomsCollectionName = "rooms"
}

@MainActor
protocol FirestoreClientInterface {
     var database: Firestore { get }
    func saveRoom(_ room: RoomDTO) async throws -> String
    func fetchRooms() async throws -> [RoomDTO]
}

final class FirestoreClient: FirestoreClientInterface {
	lazy var database: Firestore = Firestore.firestore()

	func saveRoom(_ room: RoomDTO) async throws -> String {
        let roomCollectionRef = database.collection(FirestoreConstants.roomsCollectionName)

		do {
			let documentRef = try roomCollectionRef.addDocument(from: room)
			return documentRef.documentID
		} catch {
            print("saveRoom: \(error)")
			throw error
		}
	}
    
    func fetchRooms() async throws -> [RoomDTO] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection(FirestoreConstants.roomsCollectionName).getDocuments()
        return snapshot.documents.compactMap { doc in
            print("fetchRooms from FirestoreClient: \(doc.data().values)")
            return try? RoomDTO(from: doc.data() as! Decoder)
        }
    }
}
