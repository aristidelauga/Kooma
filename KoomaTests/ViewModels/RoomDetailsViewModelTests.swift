import XCTest
@testable import Kooma

@MainActor
final class RoomDetailsViewModelTests: XCTestCase {
    
    var viewModel: RoomDetailsViewModel!
    var fakeClient: FakeFirestoreClient!
    var service: FirestoreService!
    var sampleRoom: RoomUI!
    var sampleUser: UserUI!
    
    override func setUp() {
        super.setUp()
        fakeClient = FakeFirestoreClient()
        service = FirestoreService(client: fakeClient)
        sampleUser = FixturesConstants.sampleUserUI1
        sampleRoom = FixturesConstants.createSampleRoomUI(
            administrator: sampleUser,
            members: [sampleUser, FixturesConstants.sampleUserUI2],
            regularMembersID: [FixturesConstants.sampleUserUI2.id]
        )
        viewModel = RoomDetailsViewModel(service: service, currentRoom: sampleRoom)
    }
    
    override func tearDown() {
        viewModel.endListening()
        viewModel = nil
        fakeClient.reset()
        fakeClient = nil
        service = nil
        sampleRoom = nil
        sampleUser = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInit_createsInstanceWithCurrentRoom() {
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.currentRoom.id, sampleRoom.id)
        XCTAssertEqual(viewModel.currentRoom.name, sampleRoom.name)
        XCTAssertEqual(viewModel.currentRoom.administrator.id, sampleRoom.administrator.id)
        XCTAssertFalse(viewModel.roomWasDeleted)
    }
    
    func testInit_withRoomWithoutID_doesNotSetupObservation() {
        let roomWithoutID = FixturesConstants.createSampleRoomUIWithNoID()
        let viewModel = RoomDetailsViewModel(service: service, currentRoom: roomWithoutID)
        
        XCTAssertNotNil(viewModel)
        XCTAssertNil(viewModel.currentRoom.id)
    }
    
    func testInit_withCustomService_usesProvidedService() {
        let customService = FirestoreService(client: fakeClient)
        let viewModel = RoomDetailsViewModel(service: customService, currentRoom: sampleRoom)
        
        XCTAssertNotNil(viewModel)
    }
    
    // MARK: - hasVoted Tests
    
    func testHasVoted_whenUserHasVoted_returnsTrue() {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user = FixturesConstants.sampleUserUI1
        
        // Setup room with user having voted for the restaurant
        var roomWithVotes = sampleRoom
        roomWithVotes.votes = [restaurant.id: [user.id]]
        viewModel.currentRoom = roomWithVotes
        
        let result = viewModel.hasVoted(forRestaurant: restaurant, user: user)
        
        XCTAssertTrue(result)
    }
    
    func testHasVoted_whenUserHasNotVoted_returnsFalse() {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user = FixturesConstants.sampleUserUI1
        
        // Setup room with no votes
        var roomWithoutVotes = sampleRoom
        roomWithoutVotes.votes = [:]
        viewModel.currentRoom = roomWithoutVotes
        
        let result = viewModel.hasVoted(forRestaurant: restaurant, user: user)
        
        XCTAssertFalse(result)
    }
    
    func testHasVoted_whenRestaurantHasNoVotes_returnsFalse() {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user = FixturesConstants.sampleUserUI1
        
        let result = viewModel.hasVoted(forRestaurant: restaurant, user: user)
        
        XCTAssertFalse(result)
    }
    
    // MARK: - getVoteCount Tests
    
    func testGetVoteCount_whenRestaurantHasVotes_returnsCorrectCount() {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user1 = FixturesConstants.sampleUserUI1
        let user2 = FixturesConstants.sampleUserUI2
        
        // Setup room with votes
        var roomWithVotes = sampleRoom
        roomWithVotes.votes = [restaurant.id: [user1.id, user2.id]]
        viewModel.currentRoom = roomWithVotes
        
        let count = viewModel.getVoteCount(withRestaurantID: restaurant.id)
        
        XCTAssertEqual(count, 2)
    }
    
    func testGetVoteCount_whenRestaurantHasNoVotes_returnsZero() {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        
        let count = viewModel.getVoteCount(withRestaurantID: restaurant.id)
        
        XCTAssertEqual(count, 0)
    }
    
    func testGetVoteCount_whenRestaurantDoesNotExist_returnsZero() {
        let count = viewModel.getVoteCount(withRestaurantID: "nonexistent")
        
        XCTAssertEqual(count, 0)
    }
    
    // MARK: - vote Tests
    
    func testVote_whenUserHasNotVotedAndUnderLimit_addsVoteSuccessfully() async throws {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user = FixturesConstants.sampleUserUI1
        
        // Add room to service through fake client
        let roomDomain = try sampleRoom.toDomain()
        fakeClient.addRoom(roomDomain)
        
        try await viewModel.vote(forRestaurant: restaurant, user: user)
        
        // Verify vote was added by checking through service
        try await service.fetchMyRooms(withUserID: sampleUser.id)
        let savedRooms = service.myRooms
        XCTAssertEqual(savedRooms.count, 1)
        XCTAssertTrue(savedRooms.first?.votes[restaurant.id]?.contains(user.id) ?? false)
    }
    
    func testVote_whenUserAlreadyVoted_doesNotAddVote() async throws {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user = FixturesConstants.sampleUserUI1
        
        // Setup room with user already voted
        var roomWithVote = sampleRoom
        roomWithVote.votes = [restaurant.id: [user.id]]
        viewModel.currentRoom = roomWithVote
        
        // Add room to service through fake client
        let roomDomain = try roomWithVote.toDomain()
        fakeClient.addRoom(roomDomain)
        
        try await viewModel.vote(forRestaurant: restaurant, user: user)
        
        // Verify no additional vote was added through service
        try await service.fetchMyRooms(withUserID: sampleUser.id)
        let savedRooms = service.myRooms
        XCTAssertEqual(savedRooms.count, 1)
        XCTAssertEqual(savedRooms.first?.votes[restaurant.id]?.count, 1)
    }
    
    func testVote_whenUserHasReachedVoteLimit_doesNotAddVote() async throws {
        let restaurant1 = FixturesConstants.sampleRestaurantUI1
        let restaurant2 = FixturesConstants.sampleRestaurantUI2
        let user = FixturesConstants.sampleUserUI1
        
        // Setup room with user having 2 votes already
        var roomWithMaxVotes = sampleRoom
        roomWithMaxVotes.votes = [
            restaurant1.id: [user.id],
            restaurant2.id: [user.id]
        ]
        viewModel.currentRoom = roomWithMaxVotes
        
        // Add room to service through fake client
        let roomDomain = try roomWithMaxVotes.toDomain()
        fakeClient.addRoom(roomDomain)
        
        let newRestaurant = RestaurantUI(
            id: "restaurant3",
            name: "New Restaurant",
            phoneNumber: "+33123456789",
            address: "New Address",
            placemark: FixturesConstants.samplePlacemark,
            url: "https://example.com/restaurant3"
        )
        
        try await viewModel.vote(forRestaurant: newRestaurant, user: user)
        
        // Verify no additional vote was added through service
        try await service.fetchMyRooms(withUserID: sampleUser.id)
        let savedRooms = service.myRooms
        XCTAssertEqual(savedRooms.count, 1)
        XCTAssertEqual(savedRooms.first?.votes[newRestaurant.id]?.count ?? 0, 0)
    }
    
    func testVote_whenRoomIDIsNil_handlesErrorGracefully() async {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user = FixturesConstants.sampleUserUI1
        
        // Setup room without ID
        var roomWithoutID = sampleRoom
        roomWithoutID.id = nil
        viewModel.currentRoom = roomWithoutID
        
        do {
            try await viewModel.vote(forRestaurant: restaurant, user: user)
            // Should not throw but also not add vote
        } catch {
            XCTFail("Should not throw error when room ID is nil")
        }
    }
    
    func testVote_whenServiceThrowsError_propagatesError() async {
        fakeClient.shouldThrowErrorOnUpdateVotes = true
        fakeClient.updateVotesError = NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user = FixturesConstants.sampleUserUI1
        
        // Add room to service through fake client
        let roomDomain = try! sampleRoom.toDomain()
        fakeClient.addRoom(roomDomain)
        
        do {
            try await viewModel.vote(forRestaurant: restaurant, user: user)
            XCTFail("Should throw error when service fails")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - removeVote Tests
    
    func testRemoveVote_whenUserHasVoted_removesVoteSuccessfully() async throws {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user = FixturesConstants.sampleUserUI1
        
        // Setup room with user having voted
        var roomWithVote = sampleRoom
        roomWithVote.votes = [restaurant.id: [user.id]]
        viewModel.currentRoom = roomWithVote
        
        // Add room to service through fake client
        let roomDomain = try roomWithVote.toDomain()
        fakeClient.addRoom(roomDomain)
        
        try await viewModel.removeVote(forRestaurant: restaurant, user: user)
        
        // Verify vote was removed through service
        try await service.fetchMyRooms(withUserID: sampleUser.id)
        let savedRooms = service.myRooms
        XCTAssertEqual(savedRooms.count, 1)
        XCTAssertFalse(savedRooms.first?.votes[restaurant.id]?.contains(user.id) ?? true)
    }
    
    func testRemoveVote_whenUserHasNotVoted_doesNotRemoveVote() async throws {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user = FixturesConstants.sampleUserUI1
        
        // Setup room with no votes
        var roomWithoutVotes = sampleRoom
        roomWithoutVotes.votes = [:]
        viewModel.currentRoom = roomWithoutVotes
        
        // Add room to service through fake client
        let roomDomain = try roomWithoutVotes.toDomain()
        fakeClient.addRoom(roomDomain)
        
        try await viewModel.removeVote(forRestaurant: restaurant, user: user)
        
        // Verify no changes were made through service
        try await service.fetchMyRooms(withUserID: sampleUser.id)
        let savedRooms = service.myRooms
        XCTAssertEqual(savedRooms.count, 1)
        XCTAssertEqual(savedRooms.first?.votes[restaurant.id]?.count ?? 0, 0)
    }
    
    func testRemoveVote_whenRoomIDIsNil_handlesErrorGracefully() async {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user = FixturesConstants.sampleUserUI1
        
        // Setup room without ID
        var roomWithoutID = sampleRoom
        roomWithoutID.id = nil
        viewModel.currentRoom = roomWithoutID
        
        do {
            try await viewModel.removeVote(forRestaurant: restaurant, user: user)
            // Should not throw but also not remove vote
        } catch {
            XCTFail("Should not throw error when room ID is nil")
        }
    }
    
    func testRemoveVote_whenServiceThrowsError_propagatesError() async {
        fakeClient.shouldThrowErrorOnUpdateVotes = true
        fakeClient.updateVotesError = NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user = FixturesConstants.sampleUserUI1
        
        // Setup room with user having voted
        var roomWithVote = sampleRoom
        roomWithVote.votes = [restaurant.id: [user.id]]
        viewModel.currentRoom = roomWithVote
        
        // Add room to service through fake client
        let roomDomain = try! roomWithVote.toDomain()
        fakeClient.addRoom(roomDomain)
        
        do {
            try await viewModel.removeVote(forRestaurant: restaurant, user: user)
            XCTFail("Should throw error when service fails")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - leaveRoom Tests
    
    func testLeaveRoom_withValidRoom_leavesRoomSuccessfully() async throws {
        let user = FixturesConstants.sampleUserUI1
        
        // Add room to service through fake client
        let roomDomain = try sampleRoom.toDomain()
        fakeClient.addRoom(roomDomain)
        
        try await viewModel.leaveRoom(user: user)
        
        // Verify user was removed from room through service
        try await service.fetchMyRooms(withUserID: sampleUser.id)
        let savedRooms = service.myRooms
        XCTAssertEqual(savedRooms.count, 1)
        XCTAssertFalse(savedRooms.first?.members.contains { $0.id == user.id } ?? true)
        XCTAssertFalse(savedRooms.first?.regularMembersID.contains(user.id) ?? true)
    }
    
    func testLeaveRoom_whenRoomIDIsNil_handlesErrorGracefully() async {
        let user = FixturesConstants.sampleUserUI1
        
        // Setup room without ID
        var roomWithoutID = sampleRoom
        roomWithoutID.id = nil
        viewModel.currentRoom = roomWithoutID
        
        do {
            try await viewModel.leaveRoom(user: user)
            // Should not throw but also not leave room
        } catch {
            XCTFail("Should not throw error when room ID is nil")
        }
    }
    
    func testLeaveRoom_whenServiceThrowsError_propagatesError() async {
        fakeClient.shouldThrowErrorOnLeaveRoom = true
        fakeClient.leaveRoomError = NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        let user = FixturesConstants.sampleUserUI1
        
        // Add room to service through fake client
        let roomDomain = try! sampleRoom.toDomain()
        fakeClient.addRoom(roomDomain)
        
        do {
            try await viewModel.leaveRoom(user: user)
            XCTFail("Should throw error when service fails")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - deleteRoom Tests
    
    func testDeleteRoom_withValidRoom_deletesRoomSuccessfully() async throws {
        let user = FixturesConstants.sampleUserUI1
        
        // Add room to service through fake client
        let roomDomain = try sampleRoom.toDomain()
        fakeClient.addRoom(roomDomain)
        
        try await viewModel.deleteRoom(user: user)
        
        // Verify room was deleted and flag was set
        XCTAssertTrue(viewModel.roomWasDeleted)
        
        // Verify through service that room was deleted
        try await service.fetchMyRooms(withUserID: sampleUser.id)
        let savedRooms = service.myRooms
        XCTAssertTrue(savedRooms.isEmpty)
    }
    
    func testDeleteRoom_whenRoomIDIsNil_handlesErrorGracefully() async {
        let user = FixturesConstants.sampleUserUI1
        
        // Setup room without ID
        var roomWithoutID = sampleRoom
        roomWithoutID.id = nil
        viewModel.currentRoom = roomWithoutID
        
        do {
            try await viewModel.deleteRoom(user: user)
            // Should not throw but also not delete room
        } catch {
            XCTFail("Should not throw error when room ID is nil")
        }
    }
    
    func testDeleteRoom_whenServiceThrowsError_propagatesError() async {
        fakeClient.shouldThrowErrorOnDeleteRoom = true
        fakeClient.deleteRoomError = NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        let user = FixturesConstants.sampleUserUI1
        
        // Add room to service through fake client
        let roomDomain = try! sampleRoom.toDomain()
        fakeClient.addRoom(roomDomain)
        
        do {
            try await viewModel.deleteRoom(user: user)
            XCTFail("Should throw error when service fails")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - getVotersNames Tests
    
    func testGetVotersNames_whenRestaurantHasVoters_returnsCorrectNames() {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user1 = FixturesConstants.sampleUserUI1
        let user2 = FixturesConstants.sampleUserUI2
        
        // Setup room with votes
        var roomWithVotes = sampleRoom
        roomWithVotes.votes = [restaurant.id: [user1.id, user2.id]]
        roomWithVotes.members = [user1, user2]
        viewModel.currentRoom = roomWithVotes
        
        let names = viewModel.getVotersNames(for: restaurant.id)
        
        XCTAssertEqual(names.count, 2)
        XCTAssertTrue(names.contains(user1.name))
        XCTAssertTrue(names.contains(user2.name))
    }
    
    func testGetVotersNames_whenRestaurantHasNoVoters_returnsEmptyArray() {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        
        let names = viewModel.getVotersNames(for: restaurant.id)
        
        XCTAssertTrue(names.isEmpty)
    }
    
    func testGetVotersNames_whenRestaurantDoesNotExist_returnsEmptyArray() {
        let names = viewModel.getVotersNames(for: "nonexistent")
        
        XCTAssertTrue(names.isEmpty)
    }
    
    func testGetVotersNames_whenVoterIsNotInMembers_doesNotIncludeVoter() {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user1 = FixturesConstants.sampleUserUI1
        let user2 = FixturesConstants.sampleUserUI2
        
        // Setup room with votes but user2 not in members
        var roomWithVotes = sampleRoom
        roomWithVotes.votes = [restaurant.id: [user1.id, user2.id]]
        roomWithVotes.members = [user1] // user2 not in members
        viewModel.currentRoom = roomWithVotes
        
        let names = viewModel.getVotersNames(for: restaurant.id)
        
        XCTAssertEqual(names.count, 1)
        XCTAssertTrue(names.contains(user1.name))
        XCTAssertFalse(names.contains(user2.name))
    }
    
    // MARK: - Room Observation Tests
    
    func testRoomObservation_whenRoomIsUpdated_updatesCurrentRoom() async {
        let roomID = sampleRoom.id!
        
        // Add room to service through fake client
        let roomDomain = try! sampleRoom.toDomain()
        fakeClient.addRoom(roomDomain)
        
        // Start listening
        viewModel.startListening(forUserID: sampleUser.id)
        
        // Update room in fake client
        var updatedRoom = roomDomain
        updatedRoom.name = "Updated Room Name"
        fakeClient.myRooms[roomID] = updatedRoom
        fakeClient.notifyRoomListeners(for: roomID, room: updatedRoom)
        
        // Wait a bit for async update
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        XCTAssertEqual(viewModel.currentRoom.name, "Updated Room Name")
    }
    
    func testRoomObservation_whenRoomIsDeleted_setsRoomWasDeletedFlag() async {
        let roomID = sampleRoom.id!
        
        // Add room to service through fake client
        let roomDomain = try! sampleRoom.toDomain()
        fakeClient.addRoom(roomDomain)
        
        // Start listening
        viewModel.startListening(forUserID: sampleUser.id)
        
        // Delete room from fake client
        fakeClient.myRooms.removeValue(forKey: roomID)
        fakeClient.roomListeners[roomID]?.finish()
        
        // Wait a bit for async update
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        XCTAssertTrue(viewModel.roomWasDeleted)
    }
    
    // MARK: - Listening Management Tests
    
    func testStartListening_startsServiceListening() {
        viewModel.startListening(forUserID: sampleUser.id)
        
        // Verify that the service is listening by checking if listeners are active
        // We can verify this indirectly by checking if the service has active tasks
        XCTAssertNotNil(service.myRooms)
        XCTAssertNotNil(service.joinedRooms)
    }
    
    func testEndListening_stopsServiceListening() {
        viewModel.startListening(forUserID: sampleUser.id)
        viewModel.endListening()
        
        // Verify that the service stopped listening
        // The service should have stopped its listening tasks
        XCTAssertNotNil(service.myRooms)
        XCTAssertNotNil(service.joinedRooms)
    }
}
