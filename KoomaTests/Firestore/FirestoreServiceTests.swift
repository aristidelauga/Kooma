import XCTest
@testable import Kooma


@MainActor
final class FirestoreServiceTests: XCTestCase {
    
    private var fakeClient: FakeFirestoreClient!
    private var service: FirestoreService!
    
    override func setUp() {
        super.setUp()
        fakeClient = FakeFirestoreClient()
        service = FirestoreService(client: fakeClient)
    }
    
    override func tearDown() {
        fakeClient.reset()
        service = nil
        fakeClient = nil
        super.tearDown()
    }
    
    // MARK: - createRoom Tests
    
    func testCreateRoom_Success() async throws {
        // Given
        let roomUI = FixturesConstants.createSampleRoomUI()
        
        // When
        try await service.createRoom(roomUI)
        
        // Then
        let myRooms = try await fakeClient.getMyRooms(forUserID: FixturesConstants.sampleUser1Domain.id)
        XCTAssertEqual(myRooms.count, 1)
        XCTAssertEqual(myRooms.first?.name, roomUI.name)
        XCTAssertEqual(myRooms.first?.administrator.id, roomUI.administrator.id)
    }
    
    func testCreateRoom_NoAddress() async throws {
        // Given
        var roomUI = FixturesConstants.createSampleRoomUI()
        roomUI.address = nil
        
        // When
        try await service.createRoom(roomUI)
        
        // Then - Should not create room without address
        let myRooms = try await fakeClient.getMyRooms(forUserID: FixturesConstants.sampleUser1Domain.id)
        XCTAssertEqual(myRooms.count, 0)
    }
    
    func testCreateRoom_NoImage() async throws {
        // Given
        var roomUI = FixturesConstants.createSampleRoomUI()
        roomUI.image = nil
        
        // When
        try await service.createRoom(roomUI)
        
        // Then - Should not create room without image
        let myRooms = try await fakeClient.getMyRooms(forUserID: FixturesConstants.sampleUser1Domain.id)
        XCTAssertEqual(myRooms.count, 0)
    }
    
    func testCreateRoom_ClientFailure() async {
        // Given
        let roomUI = FixturesConstants.createSampleRoomUIWithNoID()
        fakeClient.shouldThrowErrorOnSaveRoom = true
        
        // When/Then
        do {
            try await service.createRoom(roomUI)
            XCTFail("Should have thrown an error")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "RoomUI")
            XCTAssertEqual(error.code, 3)
        }
    }
    
    // MARK: - joinRoom Tests
    
    func testJoinRoom_Success() async throws {
        // Given
        let room = FixturesConstants.createSampleRoom()
        fakeClient.addRoom(room)
        let user = FixturesConstants.sampleUserUI3
        
        // When
        try await service.joinRoom(withCode: room.code, user: user)
        
        // Then
        let joinedRooms = try await fakeClient.getJoinedRooms(forUserID: user.id)
        XCTAssertEqual(joinedRooms.count, 1)
        XCTAssertEqual(joinedRooms.first?.code, room.code)
    }
    
    func testJoinRoom_RoomNotFound() async {
        // Given
        let user = FixturesConstants.sampleUserUI1
        
        // When/Then
        do {
            try await service.joinRoom(withCode: "INVALID", user: user)
            XCTFail("Should have thrown an error")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "RoomUI")
            XCTAssertEqual(error.code, 141)
        }
    }
    
    func testJoinRoom_ClientFailure() async {
        // Given
        let room = FixturesConstants.createSampleRoomWithNoID()
        fakeClient.addRoom(room)
        fakeClient.shouldThrowErrorOnJoinRoom = true
        
        // When/Then
        do {
            try await service.joinRoom(withCode: room.code, user: FixturesConstants.sampleUserUI3)
            XCTFail("Should have thrown an error")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "RoomUI")
            XCTAssertEqual(error.code, 141)
        }
    }
    
    // MARK: - leaveRoom Tests
    
    func testLeaveRoom_Success() async throws {
        // Given
        let room = FixturesConstants.createSampleRoom()
        fakeClient.addRoom(room)
        let user = FixturesConstants.sampleUserUI2
        
        // When
        try await service.leaveRoom(roomID: room.id!, user: user)
        
        // Then
        let myRooms = try await fakeClient.getMyRooms(forUserID: FixturesConstants.sampleUser1Domain.id)
        let updatedRoom = myRooms.first!
        XCTAssertFalse(updatedRoom.members.contains { $0.id == user.id })
    }
    
    func testLeaveRoom_ClientFailure() async {

        let room = FixturesConstants.createSampleRoom()
        fakeClient.addRoom(room)
        fakeClient.shouldThrowErrorOnLeaveRoom = true
        

        do {
            try await service.leaveRoom(roomID: room.id!, user: FixturesConstants.sampleUserUI2)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    
    func testDeleteRoom_Success() async throws {

        let room = FixturesConstants.createSampleRoom()
        fakeClient.addRoom(room)
        
        // When
        try await service.deleteRoom(withID: room.id!, byuserID: FixturesConstants.sampleUser1Domain.id)
        
        // Then
        let myRooms = try await fakeClient.getMyRooms(forUserID: FixturesConstants.sampleUser1Domain.id)
        XCTAssertEqual(myRooms.count, 0)
    }
    
    func testDeleteRoom_NotAuthorized() async {
        // Given
        let room = FixturesConstants.createSampleRoom()
        fakeClient.addRoom(room)
        
        // When/Then
        do {
            try await service.deleteRoom(withID: room.id!, byuserID: FixturesConstants.sampleUser2Domain.id)
            XCTFail("Should have thrown an error")
        } catch let error as NSError {
            XCTAssertEqual(error.code, 403)
        }
    }
    
    // MARK: - fetchMyRooms Tests
    
    func testFetchMyRooms_Success() async throws {
        // Given
        let room1 = FixturesConstants.createSampleRoom(id: "room1", administrator: FixturesConstants.sampleUser1Domain)
        let room2 = FixturesConstants.createSampleRoom(id: "room2", administrator: FixturesConstants.sampleUser2Domain)
        fakeClient.addRoom(room1)
        fakeClient.addRoom(room2)
        
        // When
        try await service.fetchMyRooms(withUserID: FixturesConstants.sampleUser1Domain.id)
        
        // Then
        XCTAssertEqual(service.myRooms.count, 1)
        XCTAssertEqual(service.myRooms.first?.id, "room1")
    }
    
    func testFetchMyRooms_Empty() async throws {
        // When
        try await service.fetchMyRooms(withUserID: FixturesConstants.sampleUser1Domain.id)
        
        // Then
        XCTAssertEqual(service.myRooms.count, 0)
    }
    
    func testFetchMyRooms_ClientFailure() async {
        // Given
        fakeClient.shouldThrowErrorOnGetMyRooms = true
        
        // When/Then
        do {
            try await service.fetchMyRooms(withUserID: FixturesConstants.sampleUser1Domain.id)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - fetchJoinedRooms Tests
    
    func testFetchJoinedRooms_Success() async throws {
        // Given
        let room = FixturesConstants.createSampleRoom()
        fakeClient.addRoom(room)
        
        // When
        try await service.fetchJoinedRooms(withUserID: FixturesConstants.sampleUser2Domain.id)
        
        // Then
        XCTAssertEqual(service.joinedRooms.count, 1)
        XCTAssertEqual(service.joinedRooms.first?.id, room.id)
    }
    
    func testFetchJoinedRooms_Empty() async throws {
        // When
        try await service.fetchJoinedRooms(withUserID: FixturesConstants.sampleUser1Domain.id)
        
        // Then
        XCTAssertEqual(service.joinedRooms.count, 0)
    }
    
        // MARK: - Vote Tests
    
    func testAddVote_Success() async throws {
        // Given
        let room = FixturesConstants.createSampleRoom()
        fakeClient.addRoom(room)
        
        // When
        try await service.addVote(
            forRoomID: room.id!,
            restaurantID: "restaurant2",
            userID: FixturesConstants.sampleUser1Domain.id
        )
        
        // Then
        let myRooms = try await fakeClient.getMyRooms(forUserID: FixturesConstants.sampleUser1Domain.id)
        let updatedRoom = myRooms.first!
        XCTAssertTrue(updatedRoom.votes["restaurant2"]?.contains(FixturesConstants.sampleUser1Domain.id) == true)
    }
    
    func testRemoveVote_Success() async throws {
        // Given
        let room = FixturesConstants.createSampleRoom()
        fakeClient.addRoom(room)
        
        // When
        try await service.removeVote(
            forRoomID: room.id!,
            restaurantID: "restaurant1",
            userID: FixturesConstants.sampleUser1Domain.id
        )
        
        // Then
        let myRooms = try await fakeClient.getMyRooms(forUserID: FixturesConstants.sampleUser1Domain.id)
        let updatedRoom = myRooms.first!
        XCTAssertFalse(updatedRoom.votes["restaurant1"]?.contains(FixturesConstants.sampleUser1Domain.id) == true)
    }
    
    func testAddVote_ClientFailure() async {
        // Given
        let room = FixturesConstants.createSampleRoom()
        fakeClient.addRoom(room)
        fakeClient.shouldThrowErrorOnUpdateVotes = true
        
        // When/Then
        do {
            try await service.addVote(
                forRoomID: room.id ?? ""
,
                restaurantID: "restaurant1",
                userID: FixturesConstants.sampleUser1Domain.id
            )
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - Stream Tests
    
    func testMyRoomsStream() async throws {
        // Given
        let expectation = XCTestExpectation(description: "MyRooms stream receives data")
        var receivedRooms: [[RoomDomain]] = []
        
        // When
        let stream = service.myRoomsStream(forUserID: FixturesConstants.sampleUser1Domain.id)
        
        Task {
            do {
                for try await rooms in stream {
                    receivedRooms.append(rooms)
                    if receivedRooms.count == 2 {
                        expectation.fulfill()
                        break
                    }
                }
            } catch {
                XCTFail("Stream threw an error: \(error)")
            }
        }
        
        // Add a room after a short delay
            Task {
                try await Task.sleep(for: .milliseconds(1000))
                let room = FixturesConstants.createSampleRoom()
                try await self.fakeClient.saveRoom(room)
            }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then
        XCTAssertEqual(receivedRooms.count, 2)
        XCTAssertEqual(receivedRooms[0].count, 0) // Initial empty state
        XCTAssertEqual(receivedRooms[1].count, 1) // After adding room
    }
    
    func testJoinedRoomsStream() async throws {
        // Given
        let expectation = XCTestExpectation(description: "JoinedRooms stream receives data")
        var receivedRooms: [[RoomDomain]] = []
        
        // When
        let stream = service.joinedRoomsStream(forUserID: FixturesConstants.sampleUser2Domain.id)
        
        Task {
            do {
                for try await rooms in stream {
                    receivedRooms.append(rooms)
                    if receivedRooms.count == 2 {
                        expectation.fulfill()
                        break
                    }
                }
            } catch {
                XCTFail("Stream threw an error: \(error)")
            }
        }
        
        // Add a room after a short delay where user2 is a regular member
            Task {
                try await Task.sleep(for: .milliseconds(1000))
                let room = FixturesConstants.createSampleRoom()
                self.fakeClient.addRoom(room)
                self.fakeClient.notifyJoinedRoomsListeners(for: FixturesConstants.sampleUser2Domain.id)
            }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then
        XCTAssertEqual(receivedRooms.count, 2)
        XCTAssertEqual(receivedRooms[0].count, 0) // Initial empty state
        XCTAssertEqual(receivedRooms[1].count, 1) // After adding room
    }
    
    func testRoomStream() async throws {
        // Given
        let room = FixturesConstants.createSampleRoom()
        fakeClient.addRoom(room)
        
        let expectation = XCTestExpectation(description: "Room stream receives updates")
        var receivedRooms: [RoomDomain] = []
        
        // When
        let stream = service.roomStream(withID: room.id!)
        
        Task {
            do {
                for try await updatedRoom in stream {
                    receivedRooms.append(updatedRoom)
                    if receivedRooms.count == 2 {
                        expectation.fulfill()
                        break
                    }
                }
            } catch {
                XCTFail("Stream threw an error: \(error)")
            }
        }
        
        // Update votes after a short delay
            Task {
                try await Task.sleep(for: .milliseconds(1000))
                try await self.service.addVote(
                    forRoomID: room.id!,
                    restaurantID: "restaurant2",
                    userID: FixturesConstants.sampleUser2Domain.id
                )
            }

        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Then
        XCTAssertEqual(receivedRooms.count, 2)
        XCTAssertEqual(receivedRooms[0].votes["restaurant2"]?.count ?? 0, 0) // Initial state
        XCTAssertEqual(receivedRooms[1].votes["restaurant2"]?.count ?? 0, 1) // After vote update
    }
    
    // MARK: - Integration Tests
    
    func testFullWorkflow_CreateJoinVoteLeave() async throws {
        // Given
        let adminUser = FixturesConstants.sampleUserUI1
        let regularUser = FixturesConstants.sampleUserUI2
        let roomUI = FixturesConstants.createSampleRoomUI(administrator: adminUser)
        
        // Create room
        try await service.createRoom(roomUI)
        
        // Fetch to get the created room with ID
        try await service.fetchMyRooms(withUserID: adminUser.id)
        guard let createdRoom = service.myRooms.first else {
            XCTFail("Room should have been created")
            return
        }
        
        // Join room as regular user
        try await service.joinRoom(withCode: createdRoom.code, user: regularUser)
        
        // Add vote
        try await service.addVote(
            forRoomID: createdRoom.id!,
            restaurantID: "restaurant1",
            userID: regularUser.id
        )
        
        // Verify vote was added
        let updatedMyRooms = try await fakeClient.getMyRooms(forUserID: adminUser.id)
        let roomWithVote = updatedMyRooms.first!
        XCTAssertTrue(roomWithVote.votes["restaurant1"]?.contains(regularUser.id) == true)
        
        // Leave room
        try await service.leaveRoom(roomID: createdRoom.id!, user: regularUser)
        
        // Verify user left and vote was removed
        let finalMyRooms = try await fakeClient.getMyRooms(forUserID: adminUser.id)
        let finalRoom = finalMyRooms.first!
        XCTAssertFalse(finalRoom.members.contains { $0.id == regularUser.id })
        XCTAssertFalse(finalRoom.votes["restaurant1"]?.contains(regularUser.id) == true)
    }
}
