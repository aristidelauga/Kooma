
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
    func getMyRooms(forUserID userID: String) async throws -> [RoomUI]
    func joinRoom(withCode code: String, user: UserUI) async throws
    func getJoinedRooms(forUserID userID: String) async throws -> [RoomUI]
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
    
    func joinRoom(withCode code: String, user: UserUI) async throws {
        let query = roomsCollection.whereField("code", isEqualTo: code).limit(to: 1)
        let snapshot: QuerySnapshot
        do {
            snapshot = try await query.getDocuments()
        } catch {
            throw NSError(domain: "AppError", code: 403, userInfo: [NSLocalizedDescriptionKey: "Query unsuccessful. Ended because of error: \(error)"])
        }
        
        guard let document = snapshot.documents.first else {
            throw NSError(domain: "AppError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Room with code '\(code)' not found."])
        }
        
        do {
            let userMap = try Firestore.Encoder().encode(user)
            try await document.reference.updateData([
                "members": FieldValue.arrayUnion([userMap]),
                "membersID": FieldValue.arrayUnion([user.id])
            ])
        } catch {
            throw NSError(domain: "AppError", code: 310, userInfo: [NSLocalizedDescriptionKey: "Error joining the room: \(error)"])
        }
    }
    
    func getMyRooms(forUserID userID: String) async throws -> [RoomUI] {
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
    
    func getJoinedRooms(forUserID userID: String) async throws -> [RoomUI] {
        do {
            let snapshot = try await roomsCollection.whereField("membersID", arrayContains: userID).getDocuments()
            let rooms = snapshot.documents.compactMap { document in
                try? document.data(as: RoomUI.self)
            }
            return rooms
        } catch {
            throw error
        }
    }
    
}
