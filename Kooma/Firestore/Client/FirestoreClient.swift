
import Foundation
import FirebaseCore
import Firebase
import FirebaseFirestore

private enum FirestoreConstants {
    static let roomsCollectionName = "rooms"
    static let myRoomsKey = "administrator.id"
    static let joinedRoomsKey = "regularMembersID"
    static let votesKey = "votes"
}

@MainActor
protocol FirestoreClientInterface {

    func saveRoom(_ room: RoomDomain) async throws
    func joinRoom(withCode code: String, user: UserDomain) async throws
    func leaveRoom(roomID: String, user: UserDomain) async throws
    func deleteRoom(withID: String, byuserID userID: String) async throws

    func getMyRooms(forUserID userID: String) async throws -> [RoomDomain]
    func getJoinedRooms(forUserID userID: String) async throws -> [RoomDomain]

    func updateVotes(forRoomID roomID: String, restaurantID: String, userID: String, action: VoteAction) async throws
    
    //Listeners
    func listenToMyRooms(forUserID userID: String) -> AsyncThrowingStream<[RoomDomain], Error>
    func listenToJoinedRooms(forUserID userID: String) -> AsyncThrowingStream<[RoomDomain], Error>
    func listenToRoom(withID roomID: String) -> AsyncThrowingStream<RoomDomain, Error>
}

enum VoteAction {
    case add
    case remove
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
    
    func leaveRoom(roomID: String, user: UserDomain) async throws {
        let ref = roomsCollection.document(roomID)
        let snapshot = try await ref.getDocument()
        
        var room = try snapshot.data(as: RoomDomain.self)
        
        let isAdmin = room.administrator.id == user.id
        let updatedMembers = room.members.filter { $0.id != user.id }
        
        var updatedVotes = room.votes
        for (restaurantID, voterIDs) in updatedVotes {
            updatedVotes[restaurantID] = voterIDs.filter { $0 != user.id }
        }
        
        if updatedMembers.isEmpty {
            try await ref.delete()
            print("Room \(roomID) deleted because user \(user.id) was the only member.")
            return
        }
        
        if isAdmin {
            guard let newAdmin = updatedMembers.first else {
                try await ref.delete()
                print("Room \(roomID) deleted after admin left and no other member existed.")
                return
            }
            
            // We change the admin here
            room.administrator = newAdmin
            
            // We move the room from "joinedRooms" to "myRooms" here
            room.regularMembersID.removeAll { $0 == newAdmin.id }
        }
        
        
        room.members = updatedMembers
        room.regularMembersID.removeAll { $0 == user.id }
        room.votes = updatedVotes
        
        do {
            try ref.setData(from: room)
            print("User \(user.id) removed from room \(roomID). Admin transferred if needed.")
        } catch {
            print("Error updating room \(roomID) after user \(user.id) left: \(error)")
            throw NSError(domain: "AppError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to update room after user left."])
        }
    }
    
    func deleteRoom(withID: String, byuserID userID: String) async throws {
        let ref = roomsCollection.document(withID)
        let snapshot = try await ref.getDocument()
        
        guard snapshot.exists else {
            return
        }
        
        let room = try snapshot.data(as: RoomDomain.self)
        
        guard room.administrator.id == userID else {
            throw NSError(domain: "AppError", code: 403, userInfo: [NSLocalizedDescriptionKey: "Only the administrator can delete this room."])
        }
        
        try await ref.delete()
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

    func updateVotes(forRoomID roomID: String, restaurantID: String, userID: String, action: VoteAction) async throws {
        let ref = roomsCollection.document(roomID)
        
        do {
            let snapshot = try await ref.getDocument()
            var currentVotes = snapshot.data()?[FirestoreConstants.votesKey] as? [String: [String]] ?? [:]
            
            var userIDsForRestaurant = currentVotes[restaurantID] ?? []
            
            switch action {
            case .add:
                if !userIDsForRestaurant.contains(userID) {
                    userIDsForRestaurant.append(userID)
                }
            case .remove:
                userIDsForRestaurant.removeAll(where: { $0 == userID })
            }
            
            currentVotes[restaurantID] = userIDsForRestaurant
            
            try await ref.updateData([FirestoreConstants.votesKey: currentVotes])
        } catch {
            print("updateVotes in FirestoreClient encountered an error: \(error)")
            throw error
        }
    }
    
    func listenToMyRooms(forUserID userID: String) -> AsyncThrowingStream<[RoomDomain], Error> {
        return AsyncThrowingStream { @MainActor continuation in
            let listener = roomsCollection.whereField(FirestoreConstants.myRoomsKey, isEqualTo: userID)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        continuation.finish(throwing: error)
                        return
                    }
                    
                    guard let snapshot = snapshot else {
                        continuation.finish(throwing: NSError(domain: "AppError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Snapshot was nil."]))
                        return
                    }
                    
                    let rooms = snapshot.documents.compactMap { try? $0.data(as: RoomDomain.self) }
                    continuation.yield(rooms)
                }
            
            let sendableListener = UnsafeSendableBox(listener)
            
            continuation.onTermination = { @Sendable _ in
                sendableListener.value.remove()
            }
        }
    }
    
    func listenToJoinedRooms(forUserID userID: String) -> AsyncThrowingStream<[RoomDomain], any Error> {
        return AsyncThrowingStream { @MainActor continuation in
            let listener = roomsCollection.whereField(FirestoreConstants.joinedRoomsKey, arrayContains: userID)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        continuation.finish(throwing: error)
                        return
                    }
                    
                    guard let snapshot = snapshot else {
                        continuation.finish(throwing: NSError(domain: "AppError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Snapshot was nil."]))
                        return
                    }
                    
                    let rooms = snapshot.documents.compactMap { try? $0.data(as: RoomDomain.self) }
                    continuation.yield(rooms)
                }
            
            let sendableListener = UnsafeSendableBox(listener)
            
            continuation.onTermination = { @Sendable _ in
                sendableListener.value.remove()
            }
        }
    }
    
    func listenToRoom(withID roomID: String) -> AsyncThrowingStream<RoomDomain, Error> {
        AsyncThrowingStream { continuation in
            let listener = roomsCollection.document(roomID)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        continuation.finish(throwing: error)
                        return
                    }
                    
                    guard let snapshot = snapshot else {
                        continuation.finish(throwing: NSError(
                            domain: "AppError",
                            code: 500,
                            userInfo: [NSLocalizedDescriptionKey: "Snapshot was nil."]
                        ))
                        return
                    }
                    
                    if !snapshot.exists {
                        continuation.finish()
                        return
                    }

                    do {
                        let room = try snapshot.data(as: RoomDomain.self)
                        continuation.yield(room)
                    } catch {
                        print("Decoding failed: \(error)")
                        continuation.finish(throwing: error)
                    }
                }

            let sendableListener = UnsafeSendableBox(listener)

            continuation.onTermination = { @Sendable _ in
                sendableListener.value.remove()
            }
        }
    }
    
    
}

final class UnsafeSendableBox<T>: @unchecked Sendable {
    let value: T

    init(_ value: T) {
        self.value = value
    }
}
