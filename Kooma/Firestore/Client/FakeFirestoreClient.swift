import Foundation

@MainActor
final class FakeFirestoreClient: FirestoreClientInterface {
    
    // MARK: - Mock Data Storage
    private var myRooms: [String: RoomDomain] = [:]
    private var joinedRooms: [String: RoomDomain] = [:]
    
    // MARK: - Error Simulation
    var shouldThrowErrorOnSaveRoom = false
    var shouldThrowErrorOnJoinRoom = false
    var shouldThrowErrorOnLeaveRoom = false
    var shouldThrowErrorOnDeleteRoom = false
    var shouldThrowErrorOnGetMyRooms = false
    var shouldThrowErrorOnGetJoinedRooms = false
    var shouldThrowErrorOnUpdateVotes = false
    
    var saveRoomError: Error?
    var joinRoomError: Error?
    var leaveRoomError: Error?
    var deleteRoomError: Error?
    var getMyRoomsError: Error?
    var getJoinedRoomsError: Error?
    var updateVotesError: Error?
    
    // MARK: - Listener Management
    var myRoomsListeners: [String: AsyncThrowingStream<[RoomDomain], Error>.Continuation] = [:]
    var joinedRoomsListeners: [String: AsyncThrowingStream<[RoomDomain], Error>.Continuation] = [:]
    var roomListeners: [String: AsyncThrowingStream<RoomDomain, Error>.Continuation] = [:]
    
    // MARK: - Helper Methods
    func reset() {
        myRooms.removeAll()
        joinedRooms.removeAll()
        
        // Clear all listeners
        myRoomsListeners.removeAll()
        joinedRoomsListeners.removeAll()
        roomListeners.removeAll()
        
        shouldThrowErrorOnSaveRoom = false
        shouldThrowErrorOnJoinRoom = false
        shouldThrowErrorOnLeaveRoom = false
        shouldThrowErrorOnDeleteRoom = false
        shouldThrowErrorOnGetMyRooms = false
        shouldThrowErrorOnGetJoinedRooms = false
        shouldThrowErrorOnUpdateVotes = false
        
        saveRoomError = nil
        joinRoomError = nil
        leaveRoomError = nil
        deleteRoomError = nil
        getMyRoomsError = nil
        getJoinedRoomsError = nil
        updateVotesError = nil
    }
 
    func addRoom(_ room: RoomDomain) {
        guard let roomId = room.id else {
            print("FakeFirestoreClient: Cannot add room without ID")
            return
        }
        myRooms[roomId] = room
        joinedRooms[room.code] = room
    }
    
    // MARK: - FirestoreClientInterface Implementation
    
    func saveRoom(_ room: RoomDomain) async throws {
        
        var savedRoom = room
        if !shouldThrowErrorOnSaveRoom && savedRoom.id == nil  {
            // Mimics Firestore attributing an ID to the "id" value of the room which was previously set to nil
            savedRoom.id = UUID().uuidString
        }
        
        guard let roomId = savedRoom.id else {
            throw saveRoomError ?? NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock save room error"])
        }
        
        myRooms[roomId] = savedRoom
        joinedRooms[savedRoom.code] = savedRoom
        
        // Notify listeners
        notifyMyRoomsListeners(for: savedRoom.administrator.id)
    }
    
    func joinRoom(withCode code: String, user: UserDomain) async throws {
        
        guard var room = joinedRooms[code] else {
            throw NSError(domain: "AppError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Room with code '\(code)' not found."])
        }
        
        // Add user to room if not already present
        if !room.members.contains(where: { $0.id == user.id }) {
            room.members.append(user)
        }
        
        if !shouldThrowErrorOnJoinRoom, !room.regularMembersID.contains(user.id) {
            room.regularMembersID.append(user.id)
        }
        
        guard let roomId = room.id else {
            throw joinRoomError ?? NSError(domain: "TestError", code: 403, userInfo: [NSLocalizedDescriptionKey: "Mock join room error"])
        }
        myRooms[roomId] = room
        joinedRooms[code] = room
        
        // Notify listeners
        notifyJoinedRoomsListeners(for: user.id)
        notifyRoomListeners(for: roomId, room: room)
    }
    
    func leaveRoom(roomID: String, user: UserDomain) async throws {
        if shouldThrowErrorOnLeaveRoom {
            throw leaveRoomError ?? NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock leave room error"])
        }
        
        guard var room = myRooms[roomID] else { return }
        
        let isAdmin = room.administrator.id == user.id
        room.members.removeAll { $0.id == user.id }
        room.regularMembersID.removeAll { $0 == user.id }
        
        // Remove user votes
        for (restaurantID, voterIDs) in room.votes {
            room.votes[restaurantID] = voterIDs.filter { $0 != user.id }
        }
        
        if room.members.isEmpty {
            myRooms.removeValue(forKey: roomID)
            joinedRooms.removeValue(forKey: room.code)
            return
        }
        
        if isAdmin, let newAdmin = room.members.first {
            room.administrator = newAdmin
            room.regularMembersID.removeAll { $0 == newAdmin.id }
        }
        
        myRooms[roomID] = room
        joinedRooms[room.code] = room
        
        // Notify listeners
        notifyMyRoomsListeners(for: user.id)
        notifyJoinedRoomsListeners(for: user.id)
        if isAdmin, let newAdmin = room.members.first {
            notifyMyRoomsListeners(for: newAdmin.id)
        }
        notifyRoomListeners(for: roomID, room: room)
    }
    
    func deleteRoom(withID roomID: String, byuserID userID: String) async throws {
        if shouldThrowErrorOnDeleteRoom {
            throw deleteRoomError ?? NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock delete room error"])
        }
        
        guard let room = myRooms[roomID] else { return }
        
        guard room.administrator.id == userID else {
            throw NSError(domain: "AppError", code: 403, userInfo: [NSLocalizedDescriptionKey: "Only the administrator can delete this room."])
        }
        
        myRooms.removeValue(forKey: roomID)
        joinedRooms.removeValue(forKey: room.code)
        
        // Notify listeners
        notifyMyRoomsListeners(for: userID)
        for member in room.members {
            if member.id != userID {
                notifyJoinedRoomsListeners(for: member.id)
            }
        }
    }
    
    func getMyRooms(forUserID userID: String) async throws -> [RoomDomain] {
        if shouldThrowErrorOnGetMyRooms {
            throw getMyRoomsError ?? NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock get my rooms error"])
        }
        
        return myRooms.values.filter { $0.administrator.id == userID }
    }
    
    func getJoinedRooms(forUserID userID: String) async throws -> [RoomDomain] {
        if shouldThrowErrorOnGetJoinedRooms {
            throw getJoinedRoomsError ?? NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock get joined rooms error"])
        }
        
        return myRooms.values.filter { $0.regularMembersID.contains(userID) }
    }
    
    func updateVotes(forRoomID roomID: String, restaurantID: String, userID: String, action: VoteAction) async throws {
        if shouldThrowErrorOnUpdateVotes {
            throw updateVotesError ?? NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock update votes error"])
        }
        
        guard var room = myRooms[roomID] else { return }
        
        var userIDsForRestaurant = room.votes[restaurantID] ?? []
        
        switch action {
        case .add:
            if !userIDsForRestaurant.contains(userID) {
                userIDsForRestaurant.append(userID)
            }
        case .remove:
            userIDsForRestaurant.removeAll { $0 == userID }
        }
        
        // Remove the restaurant entry if it has no votes
        if userIDsForRestaurant.isEmpty {
            room.votes.removeValue(forKey: restaurantID)
        } else {
            room.votes[restaurantID] = userIDsForRestaurant
        }
        myRooms[roomID] = room
        joinedRooms[room.code] = room
        
        // Notify room listeners
        notifyRoomListeners(for: roomID, room: room)
    }
    
    // MARK: - Listeners
    
    func listenToMyRooms(forUserID userID: String) -> AsyncThrowingStream<[RoomDomain], Error> {
        return AsyncThrowingStream { @MainActor continuation in
            myRoomsListeners[userID] = continuation
            
            // Send initial data
            let myRooms = myRooms.values.filter { $0.administrator.id == userID }
            continuation.yield(myRooms)
            
            continuation.onTermination = { @Sendable _ in
                Task { @MainActor in
                    self.myRoomsListeners.removeValue(forKey: userID)
                }
            }
        }
    }
    
    func listenToJoinedRooms(forUserID userID: String) -> AsyncThrowingStream<[RoomDomain], Error> {
        return AsyncThrowingStream { @MainActor continuation in
            joinedRoomsListeners[userID] = continuation
            
            // Send initial data
            let joinedRooms = myRooms.values.filter { $0.regularMembersID.contains(userID) }
            continuation.yield(joinedRooms)
            
            continuation.onTermination = { @Sendable _ in
                Task { @MainActor in
                    self.joinedRoomsListeners.removeValue(forKey: userID)
                }
            }
        }
    }
    
    func listenToRoom(withID roomID: String) -> AsyncThrowingStream<RoomDomain, Error> {
        return AsyncThrowingStream { @MainActor continuation in
            print("FakeFirestoreClient: listenToRoom called for room \(roomID)")
            roomListeners[roomID] = continuation
            print("FakeFirestoreClient: Added listener for room \(roomID), total listeners: \(roomListeners.count)")
            
            // Send initial data if room exists
            if let room = myRooms[roomID] {
                print("FakeFirestoreClient: Sending initial data for room \(roomID) with \(room.votes.count) votes")
                continuation.yield(room)
            } else {
                print("FakeFirestoreClient: Room \(roomID) not found, finishing stream")
                continuation.finish()
                return
            }
            
            // The stream will remain open and active until the continuation is finished
            // Future calls to notifyRoomListeners will yield new values through this continuation
            
            continuation.onTermination = { @Sendable reason in
                Task { @MainActor in
                    print("FakeFirestoreClient: Stream terminated for room \(roomID) with reason: \(reason)")
                    self.roomListeners.removeValue(forKey: roomID)
                }
            }
        }
    }
    
    // MARK: - Notification Helpers
    
    func notifyMyRoomsListeners(for userID: String) {
        guard let continuation = myRoomsListeners[userID] else { return }
        let myRooms = myRooms.values.filter { $0.administrator.id == userID }
        continuation.yield(myRooms)
    }
    
    func notifyJoinedRoomsListeners(for userID: String) {
        guard let continuation = joinedRoomsListeners[userID] else { return }
        let joinedRooms = myRooms.values.filter { $0.regularMembersID.contains(userID) }
        continuation.yield(joinedRooms)
    }
    
    func notifyRoomListeners(for roomID: String, room: RoomDomain) {
        guard let continuation = roomListeners[roomID] else {
            print("FakeFirestoreClient: No listener found for room \(roomID)")
            return 
        }
        
        continuation.yield(room)
    }
}
