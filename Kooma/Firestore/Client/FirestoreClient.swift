
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
    func getRooms() async throws -> [RoomDTO]
}

final class FirestoreClient: FirestoreClientInterface {
    lazy var database: Firestore = Firestore.firestore()
    private var roomsCollection: CollectionReference {
        database.collection(FirestoreConstants.roomsCollectionName)
    }
    
    func saveRoom(_ room: RoomDTO) async throws -> String {
        do {
            let documentRef = try self.roomsCollection.addDocument(from: room)
            return documentRef.documentID
        } catch {
            print("saveRoom: \(error)")
            throw error
        }
    }
    
    func getRooms() async throws -> [RoomDTO] {
        //        let snapshot = try await roomsCollection.getDocuments()
        //        return snapshot.documents.compactMap { doc in
        //            print("fetchRooms from FirestoreClient: \(doc.data().values)")
        //            return try? RoomDTO(from: doc.data() as! Decoder)
        //        }
        do {
            let snapshot = try await roomsCollection.getDocuments()
            let rooms = snapshot.documents.compactMap { document in
                try? document.data(as: RoomDTO.self)
            }
            print("rooms.count: \(rooms.count)")
            return rooms
        } catch {
            throw error
        }
    }
}
