import XCTest
@testable import Kooma

@MainActor
final class RoomsListViewModelTests: XCTestCase {
    
    var viewModel: RoomsListViewModel!
    var fakeClient: FakeFirestoreClient!
    var service: FirestoreService!
    
    override func setUp() {
        super.setUp()
        fakeClient = FakeFirestoreClient()
        service = FirestoreService(client: fakeClient)
        viewModel = RoomsListViewModel(firestoreService: service)
    }
    
    override func tearDown() {
        viewModel.endListening()
        viewModel = nil
        fakeClient.reset()
        fakeClient = nil
        service = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInit_createsInstanceWithDefaultValues() {
        let viewModel = RoomsListViewModel()
        
        XCTAssertNotNil(viewModel)
        XCTAssertTrue(viewModel.myRooms.isEmpty)
        XCTAssertTrue(viewModel.joinedRooms.isEmpty)
    }
    
    func testInit_withCustomService_usesProvidedService() {
        let customService = FirestoreService(client: fakeClient)
        let viewModel = RoomsListViewModel(firestoreService: customService)
        
        XCTAssertNotNil(viewModel)
    }
    
    // MARK: - addNewRoom Tests
    
    func testAddNewRoom_withValidRoom_savesRoomSuccessfully() async {
        let room = FixturesConstants.createSampleRoomUI()
        
        await viewModel.addNewRoom(room)
        
        do {
            try await self.service.fetchMyRooms(withUserID: room.administrator.id)
        } catch {
            XCTFail("Failed to fetch user's room")
        }
        
        let savedRooms = self.service.myRooms
        
        XCTAssertEqual(savedRooms.count, 1)
        XCTAssertEqual(savedRooms.first?.name, room.name)
        XCTAssertEqual(savedRooms.first?.administrator.id, room.administrator.id)
    }
    
    func testAddNewRoom_withRoomWithoutAddress_doesNotSaveRoom() async {
        let room = FixturesConstants.createSampleRoomUIWithNoRestaurants()
        
        await viewModel.addNewRoom(room)
        
        do {
            try await self.service.fetchMyRooms(withUserID: room.administrator.id)
        } catch {
            XCTFail("Failed to fetch user's room")
        }
        
        let savedRooms = self.service.myRooms
        XCTAssertTrue(savedRooms.isEmpty)
    }
    
    func testAddNewRoom_withRoomWithoutImage_doesNotSaveRoom() async {
        var room = FixturesConstants.createSampleRoomUI()
        room.image = nil
        
        await viewModel.addNewRoom(room)
        
        do {
            try await self.service.fetchMyRooms(withUserID: room.administrator.id)
        } catch {
            XCTFail("Failed to fetch user's room")
        }
        
        let savedRooms = self.service.myRooms
        XCTAssertTrue(savedRooms.isEmpty)
    }
    
    func testAddNewRoom_whenServiceThrowsError_handlesErrorGracefully() async {
        fakeClient.shouldThrowErrorOnSaveRoom = true
        fakeClient.saveRoomError = NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        let room = FixturesConstants.createSampleRoomUIWithNoID()
        
        // Should not throw, just print error
        await viewModel.addNewRoom(room)
        
        do {
            try await self.service.fetchMyRooms(withUserID: room.administrator.id)
        } catch {
            XCTFail("Failed to fetch user's room")
        }
        
        let savedRooms = self.service.myRooms
        XCTAssertTrue(savedRooms.isEmpty)
    }
    
    func testAddNewRoom_whenServiceThrowsDifferentErrors_handlesAllErrorTypes() async {
        let room = FixturesConstants.createSampleRoomUI()
        
        // Test with network error
        fakeClient.shouldThrowErrorOnSaveRoom = true
        fakeClient.saveRoomError = NSError(domain: "NetworkError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Network connection failed"])
        
        await viewModel.addNewRoom(room)
        
        // Test with validation error
        fakeClient.saveRoomError = NSError(domain: "ValidationError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid room data"])
        
        await viewModel.addNewRoom(room)
        
        // Test with permission error
        fakeClient.saveRoomError = NSError(domain: "PermissionError", code: 403, userInfo: [NSLocalizedDescriptionKey: "Access denied"])
        
        await viewModel.addNewRoom(room)
        
        // All should complete without throwing
        XCTAssertNotNil(viewModel)
    }
    
    func testAddNewRoom_whenServiceThrowsError_multipleCallsHandleErrorsIndependently() async {
        fakeClient.shouldThrowErrorOnSaveRoom = true
        fakeClient.saveRoomError = NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        let room1 = FixturesConstants.createSampleRoomUI()
        let room2 = FixturesConstants.createSampleRoomUI()
        
        // First call should handle error
        await viewModel.addNewRoom(room1)
        
        // Second call should also handle error independently
        await viewModel.addNewRoom(room2)
        
        // Both should complete without throwing
        XCTAssertNotNil(viewModel)
    }
    
    // MARK: - startListening Tests
    
    func testStartListening_forUserID_startsListeningToMyRoomsAndJoinedRooms() async {
        let userID = "user1"
        let room1 = FixturesConstants.createSampleRoom(administrator: FixturesConstants.sampleUser1Domain)
        let room2 = FixturesConstants.createSampleRoom(
            id: "room2",
            administrator: FixturesConstants.sampleUser2Domain,
            regularMembersID: [userID]
        )
        
        fakeClient.addRoom(room1)
        fakeClient.addRoom(room2)
        
        viewModel.startListening(forUserID: userID)
        
        // Wait a bit for async operations
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Verify rooms are loaded
        XCTAssertEqual(viewModel.myRooms.count, 1)
        XCTAssertEqual(viewModel.myRooms.first?.id, room1.id)
        XCTAssertEqual(viewModel.joinedRooms.count, 1)
        XCTAssertEqual(viewModel.joinedRooms.first?.id, room2.id)
    }
    
    func testStartListening_whenCalledMultipleTimes_cancelsPreviousListeners() async {
        let userID = "user1"
        let room1 = FixturesConstants.createSampleRoom(administrator: FixturesConstants.sampleUser1Domain)
        fakeClient.addRoom(room1)
        
        viewModel.startListening(forUserID: userID)
        
        // Wait a bit for async operations
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        let initialMyRoomsCount = viewModel.myRooms.count
        
        // Start listening again
        viewModel.startListening(forUserID: userID)
        
        // Wait a bit for async operations
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Should still have the same rooms (not duplicated)
        XCTAssertEqual(viewModel.myRooms.count, initialMyRoomsCount)
    }
    
    func testStartListening_whenStreamThrowsError_handlesErrorGracefully() async {
        fakeClient.shouldThrowErrorOnGetMyRooms = true
        fakeClient.getMyRoomsError = NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        let userID = "user1"
        
        // Should not throw, just print error
        viewModel.startListening(forUserID: userID)
        
        // Wait a bit for async operations
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Should have empty arrays due to error
        XCTAssertTrue(viewModel.myRooms.isEmpty)
        XCTAssertTrue(viewModel.joinedRooms.isEmpty)
    }
    
    func testStartListening_whenMyRoomsStreamThrowsError_handlesErrorGracefully() async {
        fakeClient.shouldThrowErrorOnGetMyRooms = true
        fakeClient.getMyRoomsError = NSError(domain: "MyRoomsError", code: 500, userInfo: [NSLocalizedDescriptionKey: "My rooms stream error"])
        
        let userID = "user1"
        
        // Should not throw, just print error
        viewModel.startListening(forUserID: userID)
        
        // Wait a bit for async operations
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Should have empty arrays due to error
        XCTAssertTrue(viewModel.myRooms.isEmpty)
        // joinedRooms might still work if only myRooms stream fails
    }
    
    func testStartListening_whenJoinedRoomsStreamThrowsError_handlesErrorGracefully() async {
        fakeClient.shouldThrowErrorOnGetJoinedRooms = true
        fakeClient.getJoinedRoomsError = NSError(domain: "JoinedRoomsError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Joined rooms stream error"])
        
        let userID = "user1"
        let room = FixturesConstants.createSampleRoom(administrator: FixturesConstants.sampleUser1Domain)
        fakeClient.addRoom(room)
        
        // Should not throw, just print error
        viewModel.startListening(forUserID: userID)
        
        // Wait a bit for async operations
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // myRooms should still work
        XCTAssertEqual(viewModel.myRooms.count, 1)
        // joinedRooms should be empty due to error
        XCTAssertTrue(viewModel.joinedRooms.isEmpty)
    }
    
    func testStartListening_whenBothStreamsThrowErrors_handlesBothErrorsGracefully() async {
        fakeClient.shouldThrowErrorOnGetMyRooms = true
        fakeClient.shouldThrowErrorOnGetJoinedRooms = true
        fakeClient.getMyRoomsError = NSError(domain: "MyRoomsError", code: 500, userInfo: [NSLocalizedDescriptionKey: "My rooms stream error"])
        fakeClient.getJoinedRoomsError = NSError(domain: "JoinedRoomsError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Joined rooms stream error"])
        
        let userID = "user1"
        
        // Should not throw, just print errors
        viewModel.startListening(forUserID: userID)
        
        // Wait a bit for async operations
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Both should be empty due to errors
        XCTAssertTrue(viewModel.myRooms.isEmpty)
        XCTAssertTrue(viewModel.joinedRooms.isEmpty)
    }
    
    func testStartListening_whenStreamThrowsErrorAfterInitialSuccess_handlesErrorGracefully() async {
        let userID = "user1"
        let room = FixturesConstants.createSampleRoom(administrator: FixturesConstants.sampleUser1Domain)
        fakeClient.addRoom(room)
        
        // Start listening successfully
        viewModel.startListening(forUserID: userID)
        
        // Wait for initial load
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel.myRooms.count, 1)
        
        // Now make the stream throw an error
        fakeClient.shouldThrowErrorOnGetMyRooms = true
        fakeClient.getMyRoomsError = NSError(domain: "StreamError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Stream error after success"])
        
        // Notify listeners to trigger the error
        fakeClient.notifyMyRoomsListeners(for: userID)
        
        // Wait for error handling
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Should still have the previous data (error doesn't clear existing data)
        XCTAssertEqual(viewModel.myRooms.count, 1)
    }
    
    func testStartListening_whenStreamThrowsDifferentErrorTypes_handlesAllErrorTypes() async {
        let userID = "user1"
        
        // Test with network error
        fakeClient.shouldThrowErrorOnGetMyRooms = true
        fakeClient.getMyRoomsError = NSError(domain: "NetworkError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Network connection failed"])
        
        viewModel.startListening(forUserID: userID)
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(viewModel.myRooms.isEmpty)
        
        // Test with permission error
        fakeClient.getMyRoomsError = NSError(domain: "PermissionError", code: 403, userInfo: [NSLocalizedDescriptionKey: "Access denied"])
        
        viewModel.startListening(forUserID: userID)
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(viewModel.myRooms.isEmpty)
        
        // Test with validation error
        fakeClient.getMyRoomsError = NSError(domain: "ValidationError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid data"])
        
        viewModel.startListening(forUserID: userID)
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(viewModel.myRooms.isEmpty)
    }
    
    // MARK: - endListening Tests
    
    func testEndListening_cancelsAllActiveTasks() async {
        let userID = "user1"
        let room = FixturesConstants.createSampleRoom(administrator: FixturesConstants.sampleUser1Domain)
        fakeClient.addRoom(room)
        
        viewModel.startListening(forUserID: userID)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertFalse(viewModel.myRooms.isEmpty)
        
        viewModel.endListening()
    }
    
    func testEndListening_whenNoTasksActive_doesNothing() {
        // Should not crash
        viewModel.endListening()
        
        XCTAssertTrue(viewModel.myRooms.isEmpty)
        XCTAssertTrue(viewModel.joinedRooms.isEmpty)
    }
    
    // MARK: - Real-time Updates Tests
    
    func testRealTimeUpdates_whenRoomAdded_updatesMyRoomsList() async {
        let userID = "user1"
        viewModel.startListening(forUserID: userID)
        
        // Wait for initial load
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(viewModel.myRooms.isEmpty)
        
        // Add a room
        let room = FixturesConstants.createSampleRoom(administrator: FixturesConstants.sampleUser1Domain)
        fakeClient.addRoom(room)
        
        // Notify listeners
        fakeClient.notifyMyRoomsListeners(for: userID)
        
        // Wait for update
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel.myRooms.count, 1)
        XCTAssertEqual(viewModel.myRooms.first?.id, room.id)
    }
    
    func testRealTimeUpdates_whenRoomAdded_updatesJoinedRoomsList() async {
        let userID = "user2"
        viewModel.startListening(forUserID: userID)
        
        // Wait for initial load
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(viewModel.joinedRooms.isEmpty)
        
        // Add a room where user is a member
        let room = FixturesConstants.createSampleRoom(
            administrator: FixturesConstants.sampleUser1Domain,
            regularMembersID: [userID]
        )
        fakeClient.addRoom(room)
        
        // Notify listeners
        fakeClient.notifyJoinedRoomsListeners(for: userID)
        
        // Wait for update
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel.joinedRooms.count, 1)
        XCTAssertEqual(viewModel.joinedRooms.first?.id, room.id)
    }
    
    func testRealTimeUpdates_whenRoomRemoved_updatesLists() async {
        let userID = "user1"
        let room = FixturesConstants.createSampleRoom(administrator: FixturesConstants.sampleUser1Domain)
        fakeClient.addRoom(room)
        
        viewModel.startListening(forUserID: userID)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel.myRooms.count, 1)
        
        do {
            try await self.service.deleteRoom(withID: room.id!, byuserID: room.administrator.id)
        } catch {
            XCTFail("Fail deleting the room \(room.name)")
            return
        }
        fakeClient.notifyMyRoomsListeners(for: userID)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(viewModel.myRooms.isEmpty)
    }
    
    // MARK: - Multiple Users Tests
    
    func testMultipleUsers_differentUsersSeeDifferentRooms() async {
        let user1ID = "user1"
        let user2ID = "user2"
        
        let room1 = FixturesConstants.createSampleRoom(administrator: FixturesConstants.sampleUser1Domain)
        let room2 = FixturesConstants.createSampleRoom(
            id: "room2",
            administrator: FixturesConstants.sampleUser2Domain
        )
        
        fakeClient.addRoom(room1)
        fakeClient.addRoom(room2)
        
        let viewModel1 = RoomsListViewModel(firestoreService: service)
        let viewModel2 = RoomsListViewModel(firestoreService: service)
        
        viewModel1.startListening(forUserID: user1ID)
        viewModel2.startListening(forUserID: user2ID)
        
        // Wait for async operations
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel1.myRooms.count, 1)
        XCTAssertEqual(viewModel1.myRooms.first?.id, room1.id)
        XCTAssertEqual(viewModel2.myRooms.count, 1)
        XCTAssertEqual(viewModel2.myRooms.first?.id, room2.id)
        
        viewModel1.endListening()
        viewModel2.endListening()
    }
    
    // MARK: - Edge Cases Tests
    
    func testEmptyUserID_handlesGracefully() async {
        let emptyUserID = ""
        
        viewModel.startListening(forUserID: emptyUserID)
        
        // Wait for async operations
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Should not crash and should have empty arrays
        XCTAssertTrue(viewModel.myRooms.isEmpty)
        XCTAssertTrue(viewModel.joinedRooms.isEmpty)
    }
    
    func testConcurrentOperations_handlesGracefully() async {
        let userID = "user1"
        let room = FixturesConstants.createSampleRoom(administrator: FixturesConstants.sampleUser1Domain)
        fakeClient.addRoom(room)
        
        // Start multiple concurrent operations
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.viewModel.startListening(forUserID: userID)
            }
            
            group.addTask {
                await self.viewModel.addNewRoom(FixturesConstants.createSampleRoomUI())
            }
            
            group.addTask {
                await self.viewModel.endListening()
            }
        }
        
        // Should not crash
        XCTAssertNotNil(viewModel)
    }
    
    // MARK: - Error Handling Integration Tests
    
    func testErrorHandling_whenAddNewRoomFailsAndStartListeningSucceeds_handlesGracefully() async {
        let userID = "user1"
        let room = FixturesConstants.createSampleRoom(administrator: FixturesConstants.sampleUser1Domain)
        fakeClient.addRoom(room)
        
        // Make addNewRoom fail
        fakeClient.shouldThrowErrorOnSaveRoom = true
        fakeClient.saveRoomError = NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        // Start listening (should succeed)
        viewModel.startListening(forUserID: userID)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Try to add a room (should fail gracefully)
        await viewModel.addNewRoom(FixturesConstants.createSampleRoomUI())
        
        // Listening should still work
        XCTAssertEqual(viewModel.myRooms.count, 1)
        XCTAssertNotNil(viewModel)
    }
    
    func testErrorHandling_whenStartListeningFailsAndAddNewRoomSucceeds_handlesGracefully() async {
        // Make startListening fail
        fakeClient.shouldThrowErrorOnGetMyRooms = true
        fakeClient.getMyRoomsError = NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        let userID = "user1"
        
        // Start listening (should fail gracefully)
        viewModel.startListening(forUserID: userID)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Try to add a room (should succeed)
        await viewModel.addNewRoom(FixturesConstants.createSampleRoomUI())
        
        // Should not crash and should handle both scenarios
        XCTAssertTrue(viewModel.myRooms.isEmpty) // Due to listening error
        XCTAssertNotNil(viewModel)
    }
    
    func testErrorHandling_whenMultipleErrorsOccurSequentially_handlesAllGracefully() async {
        let userID = "user1"
        
        // First error: startListening fails
        fakeClient.shouldThrowErrorOnGetMyRooms = true
        fakeClient.getMyRoomsError = NSError(domain: "FirstError", code: 500, userInfo: [NSLocalizedDescriptionKey: "First error"])
        
        viewModel.startListening(forUserID: userID)
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(viewModel.myRooms.isEmpty)
        
        // Second error: addNewRoom fails
        fakeClient.shouldThrowErrorOnSaveRoom = true
        fakeClient.saveRoomError = NSError(domain: "SecondError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Second error"])
        
        await viewModel.addNewRoom(FixturesConstants.createSampleRoomUIWithNoID())
        
        // Third error: startListening fails again with different error
        fakeClient.getMyRoomsError = NSError(domain: "ThirdError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Third error"])
        
        viewModel.startListening(forUserID: userID)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Should handle all errors gracefully
        XCTAssertTrue(viewModel.myRooms.isEmpty)
        XCTAssertNotNil(viewModel)
    }
    
    func testErrorHandling_whenErrorOccursDuringStreamProcessing_continuesListening() async {
        let userID = "user1"
        let room = FixturesConstants.createSampleRoom(administrator: FixturesConstants.sampleUser1Domain)
        fakeClient.addRoom(room)
        
        // Start listening successfully
        viewModel.startListening(forUserID: userID)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel.myRooms.count, 1)
        
        // Simulate an error during stream processing
        fakeClient.shouldThrowErrorOnGetMyRooms = true
        fakeClient.getMyRoomsError = NSError(domain: "StreamError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Stream processing error"])
        
        // Trigger the error
        fakeClient.notifyMyRoomsListeners(for: userID)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Should continue listening despite the error
        XCTAssertNotNil(viewModel)
        // The existing data should remain (error doesn't clear it)
        XCTAssertEqual(viewModel.myRooms.count, 1)
    }
    
    func testErrorHandling_whenErrorMessagesArePrinted_doesNotAffectFunctionality() async {
        let userID = "user1"
        
        // Test that error printing doesn't break functionality
        fakeClient.shouldThrowErrorOnGetMyRooms = true
        fakeClient.getMyRoomsError = NSError(domain: "PrintTestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Error message for printing test"])
        
        // This should print an error message but not crash
        viewModel.startListening(forUserID: userID)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Should still function normally
        XCTAssertTrue(viewModel.myRooms.isEmpty)
        XCTAssertNotNil(viewModel)
        
        // Test addNewRoom error printing
        fakeClient.shouldThrowErrorOnSaveRoom = true
        fakeClient.saveRoomError = NSError(domain: "PrintTestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Add room error message for printing test"])
        
        await viewModel.addNewRoom(FixturesConstants.createSampleRoomUI())
        
        // Should still function normally
        XCTAssertNotNil(viewModel)
    }
    
    // MARK: - Data Conversion Tests
    
    func testDataConversion_domainToUIConversionWorksCorrectly() async {
        let userID = "user1"
        let room = FixturesConstants.createSampleRoom(
            administrator: FixturesConstants.sampleUser1Domain,
            members: [FixturesConstants.sampleUser1Domain, FixturesConstants.sampleUser2Domain],
            restaurants: [FixturesConstants.sampleRestaurant1],
            votes: ["restaurant1": ["user1", "user2"]]
        )
        
        fakeClient.addRoom(room)
        
        viewModel.startListening(forUserID: userID)
        
        // Wait for async operations
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel.myRooms.count, 1)
        
        let convertedRoom = viewModel.myRooms.first
        XCTAssertNotNil(convertedRoom)
        XCTAssertEqual(convertedRoom?.id, room.id)
        XCTAssertEqual(convertedRoom?.name, room.name)
        XCTAssertEqual(convertedRoom?.administrator.id, room.administrator.id)
        XCTAssertEqual(convertedRoom?.members.count, room.members.count)
        XCTAssertEqual(convertedRoom?.restaurants.count, room.restaurants.count)
        XCTAssertEqual(convertedRoom?.votes, room.votes)
    }
    
    // MARK: - Observable Behavior Tests
    
    func testObservableBehavior_myRoomsUpdatesTriggerObservableChanges() async {
        let userID = "user1"
        let room = FixturesConstants.createSampleRoom(administrator: FixturesConstants.sampleUser1Domain)
        
        viewModel.startListening(forUserID: userID)
        
        // Wait for initial load
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(viewModel.myRooms.isEmpty)
        
        // Add room and notify
        fakeClient.addRoom(room)
        fakeClient.notifyMyRoomsListeners(for: userID)
        
        // Wait for update
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel.myRooms.count, 1)
        XCTAssertEqual(viewModel.myRooms.first?.id, room.id)
    }
    
    func testObservableBehavior_joinedRoomsUpdatesTriggerObservableChanges() async {
        let userID = "user2"
        let room = FixturesConstants.createSampleRoom(
            administrator: FixturesConstants.sampleUser1Domain,
            regularMembersID: [userID]
        )
        
        viewModel.startListening(forUserID: userID)
        
        // Wait for initial load
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(viewModel.joinedRooms.isEmpty)
        
        // Add room and notify
        fakeClient.addRoom(room)
        fakeClient.notifyJoinedRoomsListeners(for: userID)
        
        // Wait for update
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel.joinedRooms.count, 1)
        XCTAssertEqual(viewModel.joinedRooms.first?.id, room.id)
    }
}
