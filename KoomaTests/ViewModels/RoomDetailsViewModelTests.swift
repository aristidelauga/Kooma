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
            regularMembersID: [FixturesConstants.sampleUserUI2.id],
            votes: [:]
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
        
        guard var roomWithVotes = sampleRoom else {
            XCTFail("No votes for this room fetched")
            return
        }
        
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
        roomWithoutVotes?.votes = [:]
        viewModel.currentRoom = roomWithoutVotes!
        
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
        var roomWithVotes: RoomUI = sampleRoom
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
    
    
    func testVote_whenUserHasNotVotedAndUnderLimit_addsVoteSuccessfully() async throws {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user = FixturesConstants.sampleUserUI1
        
        // Add room to fake client
        let roomDomain = RoomDomain(
            id: sampleRoom.id,
            code: sampleRoom.code,
            name: sampleRoom.name,
            administrator: try sampleRoom.administrator.toDomain(),
            address: sampleRoom.address!,
            members: try sampleRoom.members.compactMap { try $0.toDomain() },
            regularMembersID: sampleRoom.regularMembersID,
            restaurants: try sampleRoom.restaurants.compactMap { try $0.toDomain() },
            votes: sampleRoom.votes,
            image: sampleRoom.image!
        )
        fakeClient.addRoom(roomDomain)
        
        // Ensure viewModel's currentRoom matches the fake client state
        viewModel.currentRoom = sampleRoom
        
        try await viewModel.vote(forRestaurant: restaurant, user: user)
        
        // Verify vote was added by checking the updated room
        let updatedRooms = try await fakeClient.getMyRooms(forUserID: sampleRoom.administrator.id)
        let updatedRoom = updatedRooms.first(where: { $0.id == sampleRoom.id })
        XCTAssertNotNil(updatedRoom)
        XCTAssertTrue(updatedRoom?.votes[restaurant.id]?.contains(user.id) ?? false)
    }
    
    func testVote_whenUserAlreadyVoted_doesNotAddVote() async throws {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user = FixturesConstants.sampleUserUI1
        
        // Setup room with user already voted
        var roomWithVote: RoomUI = sampleRoom
        roomWithVote.votes = [restaurant.id: [user.id]]
        
        try await service.createRoom(roomWithVote)
        
        // Then set the viewModel's currentRoom to match
        viewModel.currentRoom = roomWithVote
        
        try await viewModel.vote(forRestaurant: restaurant, user: user)
        
        // Verify no additional vote was added
        let updatedRooms = try await fakeClient.getMyRooms(forUserID: sampleRoom.administrator.id)
        let updatedRoom = updatedRooms.first
        XCTAssertNotNil(updatedRoom)
        XCTAssertEqual(updatedRoom?.votes[restaurant.id]?.count, 1)
    }
    
    func testVote_whenUserHasReachedVoteLimit_doesNotAddVote() async throws {
        let restaurant1 = FixturesConstants.sampleRestaurantUI1
        let restaurant2 = FixturesConstants.sampleRestaurantUI2
        let user = FixturesConstants.sampleUserUI1
        
        // Setup room with user having 2 votes already
        var roomWithMaxVotes: RoomUI = sampleRoom
        roomWithMaxVotes.votes = [
            restaurant1.id: [user.id],
            restaurant2.id: [user.id]
        ]
        
        try await service.createRoom(roomWithMaxVotes)
        
        // Then set the viewModel's currentRoom to match
        viewModel.currentRoom = roomWithMaxVotes
        
        let newRestaurant = RestaurantUI(
            id: "restaurant3",
            name: "New Restaurant",
            phoneNumber: "+33123456789",
            address: "New Address",
            placemark: FixturesConstants.samplePlacemark,
            url: "https://example.com/restaurant3"
        )
        
        try await viewModel.vote(forRestaurant: newRestaurant, user: user)
        
        // Verify no additional vote was added
        let updatedRooms = try await fakeClient.getMyRooms(forUserID: sampleRoom.administrator.id)
        let updatedRoom = updatedRooms.first
        XCTAssertNotNil(updatedRoom)
        XCTAssertEqual(updatedRoom?.votes[newRestaurant.id]?.count ?? 0, 0)
    }
    
    func testVote_whenRoomIDIsNil_handlesErrorGracefully() async {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user = FixturesConstants.sampleUserUI1
        
        // Setup room without ID
        var roomWithoutID: RoomUI = sampleRoom
        roomWithoutID.id = nil
        viewModel.currentRoom = roomWithoutID
        
        do {
            try await viewModel.vote(forRestaurant: restaurant, user: user)
            // Should not throw but also not add vote
        } catch {
            XCTFail("Should not throw error when room ID is nil")
        }
    }
    
    func testVote_whenServiceThrowsError_propagatesError() async throws {
        fakeClient.shouldThrowErrorOnUpdateVotes = true
        fakeClient.updateVotesError = NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user = FixturesConstants.sampleUserUI1
        
        try await service.createRoom(sampleRoom)
        
        // Ensure viewModel's currentRoom matches the fake client state
        viewModel.currentRoom = sampleRoom
        
        do {
            try await viewModel.vote(forRestaurant: restaurant, user: user)
            XCTFail("Should throw error when service fails")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func test_removeVote_removesUserVote() async throws {
        let user = UserUI(id: "user1", name: "Alice")
        let restaurant = RestaurantUI(
            id: "rest1",
            name: "Pizza Place",
            phoneNumber: "123456789",
            address: "123 Main St",
            placemark: FixturesConstants.parisPlacemark,
            url: "http://pizza.com"
        )
        let roomDomain = RoomDomain(
            id: "room1",
            code: "CODE1",
            name: "Test Room",
            administrator: try user.toDomain(),
            address: "Paris, France",
            members: [try user.toDomain()],
            regularMembersID: [],
            restaurants: [try restaurant.toDomain()],
            votes: [restaurant.id: [user.id]],
            image: "RoomOne"
        )
        
        fakeClient.addRoom(roomDomain)
        let roomUI = roomDomain.toUI()
        viewModel = RoomDetailsViewModel(service: service, currentRoom: roomUI)

        // Act
        try await viewModel.removeVote(forRestaurant: restaurant, user: user)

        // Assert
        let updatedRooms = try await fakeClient.getMyRooms(forUserID: user.id)
        let updatedRoom = updatedRooms.first(where: { $0.id == "room1" })
        let votes = updatedRoom?.votes[restaurant.id] ?? []
        XCTAssertFalse(votes.contains(user.id), "User's vote should be removed")
    }
    
    func testRemoveVote_whenUserHasNotVoted_doesNotRemoveVote() async throws {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user = FixturesConstants.sampleUserUI1
        
        // Setup room with no votes
        var roomWithoutVotes: RoomUI = sampleRoom
        roomWithoutVotes.votes = [:]
        
        try await service.createRoom(roomWithoutVotes)
        
        // Then set the viewModel's currentRoom to match
        viewModel.currentRoom = roomWithoutVotes
        
        try await viewModel.removeVote(forRestaurant: restaurant, user: user)
        
        // Verify no changes were made
        let updatedRooms = try await fakeClient.getMyRooms(forUserID: sampleRoom.administrator.id)
        let updatedRoom = updatedRooms.first
        XCTAssertNotNil(updatedRoom)
        XCTAssertEqual(updatedRoom?.votes[restaurant.id]?.count ?? 0, 0)
    }
    
    func testRemoveVote_whenRoomIDIsNil_handlesErrorGracefully() async {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user = FixturesConstants.sampleUserUI1
        
        // Setup room without ID
        var roomWithoutID: RoomUI = sampleRoom
        roomWithoutID.id = nil
        viewModel.currentRoom = roomWithoutID
        
        do {
            try await viewModel.removeVote(forRestaurant: restaurant, user: user)
            // Should not throw but also not remove vote
        } catch {
            XCTFail("Should not throw error when room ID is nil")
        }
    }
    
    func testRemoveVote_whenServiceThrowsError_propagatesError() async throws {
        fakeClient.shouldThrowErrorOnUpdateVotes = true
        fakeClient.updateVotesError = NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user = FixturesConstants.sampleUserUI1
        
        // Setup room with user having voted
        var roomWithVote: RoomUI = sampleRoom
        roomWithVote.votes = [restaurant.id: [user.id]]
        
        try await service.createRoom(roomWithVote)
        
        // Then set the viewModel's currentRoom to match
        viewModel.currentRoom = roomWithVote
        
        do {
            try await viewModel.removeVote(forRestaurant: restaurant, user: user)
            XCTFail("Should throw error when service fails")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testLeaveRoom_whenRoomIDIsNil_handlesErrorGracefully() async {
        let user = FixturesConstants.sampleUserUI1
        
        // Setup room without ID
        var roomWithoutID: RoomUI = sampleRoom
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
        
        // Add room to fake client
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
        
        // Add room to fake client
        let roomDomain = try sampleRoom.toDomain()
        fakeClient.addRoom(roomDomain)
        
        try await viewModel.deleteRoom(user: user)
        
        // Verify room was deleted and flag was set
        XCTAssertTrue(viewModel.roomWasDeleted)
    }
    
    func testDeleteRoom_whenRoomIDIsNil_handlesErrorGracefully() async {
        let user = FixturesConstants.sampleUserUI1
        
        // Setup room without ID
        var roomWithoutID: RoomUI = sampleRoom
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
        
        // Add room to fake client
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
        var roomWithVotes: RoomUI = sampleRoom
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
        var roomWithVotes: RoomUI = sampleRoom
        roomWithVotes.votes = [restaurant.id: [user1.id, user2.id]]
        roomWithVotes.members = [user1] // user2 not in members
        viewModel.currentRoom = roomWithVotes
        
        let names = viewModel.getVotersNames(for: restaurant.id)
        
        XCTAssertEqual(names.count, 1)
        XCTAssertTrue(names.contains(user1.name))
        XCTAssertFalse(names.contains(user2.name))
    }
    
    func testStartListening_startsServiceListening() {
        viewModel.startListening(forUserID: sampleUser.id)
        
        // Verify that the service is listening by checking if the viewModel is listening
        XCTAssertTrue(viewModel.isListening())
    }
    
    func testFakeFirestoreClientListenersAreWorking() async throws {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user = FixturesConstants.sampleUserUI1

        let roomDomain = try sampleRoom.toDomain()
        fakeClient.addRoom(roomDomain)

        let roomStream = fakeClient.listenToRoom(withID: roomDomain.id!)
        var receivedUpdates: [RoomDomain] = []

        let listeningTask = Task {
            for try await room in roomStream {
                receivedUpdates.append(room)
            }
        }

        // Wait for initial data
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(receivedUpdates.count, 1, "Should receive initial room data")
        XCTAssertEqual(receivedUpdates.first?.votes.count, 0, "Initial room should have no votes")

        try await fakeClient.updateVotes(forRoomID: roomDomain.id!, restaurantID: restaurant.id, userID: user.id, action: .add)

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(receivedUpdates.count, 2, "Should receive both initial data and update")
        XCTAssertEqual(receivedUpdates.last?.votes.count, 1, "Updated room should have 1 vote")

        listeningTask.cancel()
    }
    
    func testFakeFirestoreClientNotifyRoomListenersIsWorking() async throws {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let user = FixturesConstants.sampleUserUI1
        
        // Create a room and add it to fake client
        let roomDomain = try sampleRoom.toDomain()
        fakeClient.addRoom(roomDomain)
        
        // Set up a listener for the room
        let roomStream = fakeClient.listenToRoom(withID: roomDomain.id!)
        var receivedUpdates: [RoomDomain] = []
        
        // Start listening in a separate task
        let listeningTask = Task {
            for try await room in roomStream {
                receivedUpdates.append(room)
            }
        }
        
        // Wait for initial data
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify initial state
        XCTAssertEqual(receivedUpdates.count, 1, "Should receive initial room data")
        
        // Manually notify room listeners
        var updatedRoom = roomDomain
        updatedRoom.votes[restaurant.id] = [user.id]
        fakeClient.notifyRoomListeners(for: roomDomain.id!, room: updatedRoom)
        
        // Wait for the update to propagate
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify that the listener received the update
        XCTAssertEqual(receivedUpdates.count, 2, "Should receive both initial data and manual notification")
        XCTAssertEqual(receivedUpdates.last?.votes.count, 1, "Updated room should have 1 vote")
        
        // Clean up
        listeningTask.cancel()
    }
    
    
    func testFakeFirestoreClientStreamStaysOpen() async throws {
        
        // Create a room and add it to fake client
        let roomDomain = try sampleRoom.toDomain()
        fakeClient.addRoom(roomDomain)
        
        // Set up a listener for the room
        let roomStream = fakeClient.listenToRoom(withID: roomDomain.id!)
        var receivedUpdates: [RoomDomain] = []
        
        // Start listening in a separate task
        let listeningTask = Task {
            for try await room in roomStream {
                receivedUpdates.append(room)
            }
        }
        
        // Wait for initial data
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Test manual notification
        var updatedRoom = roomDomain
        updatedRoom.votes["test"] = ["test"]
        fakeClient.notifyRoomListeners(for: roomDomain.id!, room: updatedRoom)
        
        // Wait for the update to propagate
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify we got both initial data and the update
        XCTAssertEqual(receivedUpdates.count, 2, "Should receive both initial data and manual notification")
        
        // Clean up
        listeningTask.cancel()
    }
}
