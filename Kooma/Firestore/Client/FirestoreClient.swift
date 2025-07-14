
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
    func saveRoom(_ room: RoomUI) async throws -> String
    func getRooms(forUserID userID: String) async throws -> [RoomUI]
}

final class FirestoreClient: FirestoreClientInterface {
    lazy var database: Firestore = Firestore.firestore()
    private var roomsCollection: CollectionReference {
        database.collection(FirestoreConstants.roomsCollectionName)
    }
    
    func saveRoom(_ room: RoomUI) async throws -> String {
        do {
            let documentRef = try self.roomsCollection.addDocument(from: room)
            return documentRef.documentID
        } catch {
            print("saveRoom: \(error)")
            throw error
        }
    }
    
    func getRooms(forUserID userID: String) async throws -> [RoomUI] {
        do {
            let snapshot = try await roomsCollection.whereField("administrator.id", isEqualTo: userID).getDocuments()
            let rooms = snapshot.documents.compactMap { document in
                try? document.data(as: RoomUI.self)
            }
            return rooms
        } catch {
            throw error
        }
    }
}
