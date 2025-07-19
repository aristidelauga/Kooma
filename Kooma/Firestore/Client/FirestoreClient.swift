
import Foundation
import FirebaseCore
import Firebase
import FirebaseFirestore

private enum FirestoreConstants {
    static let roomsCollectionName = "rooms"
    static let myRoomsKey = "administrator.id"
    static let joinedRoomsKey = "regularMembersID"
}

@MainActor
protocol FirestoreClientInterface {
    var database: Firestore { get }
    func saveRoom(_ room: RoomDomain) async throws
    func getMyRooms(forUserID userID: String) async throws -> [RoomDomain]
    func joinRoom(withCode code: String, user: UserDomain) async throws
    func getJoinedRooms(forUserID userID: String) async throws -> [RoomDomain]
    func updateVotes(forRoomID roomID: String, votes: [String: [String]]) async throws
}

final class FirestoreClient: FirestoreClientInterface {
    lazy var database: Firestore = Firestore.firestore()
    private var roomsCollection: CollectionReference {
        database.collection(FirestoreConstants.roomsCollectionName)
    }
    
    func saveRoom(_ room: RoomDomain) async throws {
        do {
            try self.roomsCollection.addDocument(from: room)
        } catch {
            print("saveRoom: \(error)")
            throw error
        }
    }
    
    func joinRoom(withCode code: String, user: UserDomain) async throws {
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
                "regularMembersID": FieldValue.arrayUnion([user.id])
            ])
        } catch {
            throw NSError(domain: "AppError", code: 310, userInfo: [NSLocalizedDescriptionKey: "Error joining the room: \(error)"])
        }
    }
    
    func getMyRooms(forUserID userID: String) async throws -> [RoomDomain] {
        do {
            let snapshot = try await roomsCollection.whereField(FirestoreConstants.myRoomsKey, isEqualTo: userID).getDocuments()
            let rooms = snapshot.documents.compactMap { document in
                try? document.data(as: RoomDomain.self)
            }
            return rooms
        } catch {
            throw error
        }
    }
    
    func getJoinedRooms(forUserID userID: String) async throws -> [RoomDomain] {
        do {
            let snapshot = try await roomsCollection.whereField(FirestoreConstants.joinedRoomsKey, arrayContains: userID).getDocuments()
            let rooms = snapshot.documents.compactMap { document in
                try? document.data(as: RoomDomain.self)
            }
            return rooms
        } catch {
            throw error
        }
    }
    
    func updateVotes(forRoomID roomID: String, votes: [String : [String]]) async throws {
        let ref = roomsCollection.document(roomID)
        try await ref.updateData(["votes": votes])
    }

}
