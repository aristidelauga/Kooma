import XCTest
@testable import Kooma

@MainActor
final class ResearchRoomViewModelTests: XCTestCase {
    
    var mockClient: FakeFirestoreClient!
    var service: FirestoreService!
    var viewModel: ResearchRoomViewModel!
    
    override func setUp() {
        super.setUp()
        mockClient = FakeFirestoreClient()
        service = FirestoreService(client: mockClient)
        viewModel = ResearchRoomViewModel(service: service)
    }
    
    override func tearDown() {
        mockClient.reset()
        mockClient = nil
        service = nil
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInit_withService_createsInstance() {
        let viewModel = ResearchRoomViewModel(service: service)
        
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.joinedRooms.count, 0)
    }
    
    func testInit_withDefaultService_createsInstance() {
        let viewModel = ResearchRoomViewModel()
        
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.joinedRooms.count, 0)
    }
    
    // MARK: - joinRoom Tests
    
    func testJoinRoom_withValidCodeAndNotAlreadyJoined_succeeds() async throws {
        // Given
        let roomCode = "ABC123"
        let user = FixturesConstants.sampleUserUI3
        let room = FixturesConstants.createSampleRoom(code: roomCode)
        mockClient.addRoom(room)
        
        // When
        try await viewModel.joinRoom(code: roomCode, user: user)
        
        // Then
        let joinedRooms = try await mockClient.getJoinedRooms(forUserID: user.id)
        XCTAssertEqual(joinedRooms.count, 1)
        XCTAssertEqual(joinedRooms.first?.code, roomCode)
    }
    
    func testJoinRoom_whenAlreadyJoined_throwsAlreadyJoinedError() async {
        // Given
        let roomCode = "ABC123"
        let user = FixturesConstants.sampleUserUI3
        let room = FixturesConstants.createSampleRoom(code: roomCode)
        mockClient.addRoom(room)
        
        do {
            try await mockClient.joinRoom(withCode: roomCode, user: user.toDomain())
        } catch {
            XCTFail("Failed to join room: \(error)")
        }
        
        do {
            try await viewModel.fetchJoinedRooms(userID: user.id)
        } catch {
            XCTFail("Failed to fetch rooms: \(error)")
        }
        
        // When/Then
        do {
            try await viewModel.joinRoom(code: roomCode, user: user)
            XCTFail("Should have thrown alreadyJoined error")
        } catch let error as JoinRoomError {
            XCTAssertEqual(error, .alreadyJoined)
        } catch {
            XCTFail("Should have thrown JoinRoomError.alreadyJoined, but got \(error)")
        }
    }
    
	func testJoinRoom_whenUserIsAdministrator_throwsAdministratorError() async throws {
		// Given
		let roomCode = "ADMIN_ROOM"
		let adminUser = FixturesConstants.sampleUserUI1
		let room = FixturesConstants.createSampleRoom(code: roomCode, administrator: try adminUser.toDomain())
		mockClient.addRoom(room)

		try await viewModel.fetchMyRooms(userID: adminUser.id)

		// When/Then
		do {
			try await viewModel.joinRoom(code: roomCode, user: adminUser)
			XCTFail("Should have thrown administrator error")
		} catch let error as JoinRoomError {
			XCTAssertEqual(error, .administrator)
		} catch {
			XCTFail("Should have thrown JoinRoomError.administrator but received \(error) instead")
		}
	}

    func testJoinRoom_whenServiceThrowsError_throwsUnableToFindRoomError() async {
        // Given
        let roomCode = "NON_EXISTENT_ROOM"
        let user = FixturesConstants.sampleUserUI3
        
        // When/Then
        do {
            try await viewModel.joinRoom(code: roomCode, user: user)
            XCTFail("Should have thrown unableToFindRoom error")
        } catch let error as JoinRoomError {
            XCTAssertEqual(error, .unableToFindRoom)
        } catch {
            XCTFail("Should have thrown JoinRoomError.unableToFindRoom, but got \(error)")
        }
    }
    
    func testJoinRoom_whenRoomNotFound_throwsError() async {
        // Given
        let roomCode = "INVALID"
        let user = FixturesConstants.sampleUserUI3
        
        // When/Then
        do {
            try await viewModel.joinRoom(code: roomCode, user: user)
            XCTFail("Should have thrown an error")
        } catch let error as JoinRoomError {
            XCTAssertEqual(error, .unableToFindRoom)
        } catch {
            XCTFail("Should have thrown NSError, but got \(error)")
        }
    }
    
    func testJoinRoom_withEmptyCode_throwsError() async {
        // Given
        let roomCode = ""
        let user = FixturesConstants.sampleUserUI3
        
        // When/Then
        do {
            try await viewModel.joinRoom(code: roomCode, user: user)
            XCTFail("Should have thrown an error")
        } catch let error as JoinRoomError {
            XCTAssertEqual(error, .unableToFindRoom)
        } catch {
            XCTFail("Should have thrown NSError, but got \(error)")
        }
    }
    
    func testJoinRoom_withWhitespaceCode_throwsError() async {
        // Given
        let roomCode = "   "
        let user = FixturesConstants.sampleUserUI3
        
        // When/Then
        do {
            try await viewModel.joinRoom(code: roomCode, user: user)
            XCTFail("Should have thrown an error")
        } catch let error as JoinRoomError {
            XCTAssertEqual(error, .unableToFindRoom)
        } catch {
            XCTFail("Should have thrown NSError, but got \(error)")
        }
    }
    
    func testJoinRoom_whenClientThrowsError_throwsError() async {
        // Given
        let roomCode = "ABC123"
        let user = FixturesConstants.sampleUserUI3
        mockClient.shouldThrowErrorOnJoinRoom = true
        
        do {
            try await viewModel.joinRoom(code: roomCode, user: user)
            XCTFail("Should have thrown an error")
        } catch let error as JoinRoomError {
            XCTAssertEqual(error, .unableToFindRoom)
        } catch {
            XCTFail("Should have thrown NSError, but got \(error)")
        }
    }
    
    func testFetchJoinedRooms_withValidUserID_succeeds() async throws {
        let userID = FixturesConstants.sampleUserUI2.id
        let room = FixturesConstants.createSampleRoom()
        mockClient.addRoom(room)
        
        try await viewModel.fetchJoinedRooms(userID: userID)
        
        XCTAssertEqual(viewModel.joinedRooms.count, 1)
        XCTAssertEqual(viewModel.joinedRooms.first?.id, room.id)
    }
    
    func testFetchJoinedRooms_whenClientThrowsError_propagatesError() async {
        let userID = FixturesConstants.sampleUserUI2.id
        mockClient.shouldThrowErrorOnGetJoinedRooms = true
        
        do {
            try await viewModel.fetchJoinedRooms(userID: userID)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testFetchJoinedRooms_withEmptyUserID_returnsEmptyArray() async throws {
        let userID = ""
        
        try await viewModel.fetchJoinedRooms(userID: userID)
        
        XCTAssertEqual(viewModel.joinedRooms.count, 0)
    }
    
    func testFetchJoinedRooms_convertsDomainRoomsToUIRooms() async throws {
        let userID = FixturesConstants.sampleUserUI2.id
        let room1 = FixturesConstants.createSampleRoom(id: "room1", administrator: FixturesConstants.sampleUser1Domain)
        let room2 = FixturesConstants.createSampleRoom(id: "room2", administrator: FixturesConstants.sampleUser2Domain)
        
        mockClient.addRoom(room1)
        mockClient.addRoom(room2)
        
        try await viewModel.fetchJoinedRooms(userID: userID)
        
        XCTAssertEqual(viewModel.joinedRooms.count, 2)
        
        let roomIds = viewModel.joinedRooms.map { $0.id }
        XCTAssertTrue(roomIds.contains(room1.id))
        XCTAssertTrue(roomIds.contains(room2.id))
    }
    
    func testFetchJoinedRooms_updatesJoinedRoomsFromService() async throws {
        // Given
        let userID = FixturesConstants.sampleUserUI2.id
        let room = FixturesConstants.createSampleRoom()
        mockClient.addRoom(room)
        
        // When
        try await viewModel.fetchJoinedRooms(userID: userID)
        
        // Then
        XCTAssertEqual(viewModel.joinedRooms.count, 1)
        XCTAssertEqual(viewModel.joinedRooms.first?.id, room.id)
        XCTAssertEqual(viewModel.joinedRooms.first?.name, room.name)
        XCTAssertEqual(viewModel.joinedRooms.first?.administrator.id, room.administrator.id)
    }
    
    // MARK: - Integration Tests
    
    func testJoinRoomFlow_withValidCode_succeeds() async throws {
        // Given
        let roomCode = "ABC123"
        let user = FixturesConstants.sampleUserUI3
        let room = FixturesConstants.createSampleRoom(code: roomCode)
        mockClient.addRoom(room)
        
        // When
        try await viewModel.fetchJoinedRooms(userID: user.id)
        try await viewModel.joinRoom(code: roomCode, user: user)
        
        let joinedRooms = try await mockClient.getJoinedRooms(forUserID: user.id)
        XCTAssertEqual(joinedRooms.count, 1)
        XCTAssertEqual(joinedRooms.first?.code, roomCode)
    }
    
    func testJoinRoomFlow_whenAlreadyJoined_preventsJoining() async throws {
        let roomCode = "ABC123"
        let user = FixturesConstants.sampleUserUI3
        let room = FixturesConstants.createSampleRoom(code: roomCode)
        mockClient.addRoom(room)
        
        try await mockClient.joinRoom(withCode: roomCode, user: user.toDomain())
        
        try await viewModel.fetchJoinedRooms(userID: user.id)
        
        do {
            try await viewModel.joinRoom(code: roomCode, user: user)
            XCTFail("Should have thrown alreadyJoined error")
        } catch let error as JoinRoomError {
            XCTAssertEqual(error, .alreadyJoined)
        } catch {
            XCTFail("Should have thrown JoinRoomError.alreadyJoined, but got \(error)")
        }
    }
    
    // MARK: - Edge Cases
    
    func testJoinRoom_withSpecialCharactersInCode_throwsError() async {
        let roomCode = "ABC-123"
        let user = FixturesConstants.sampleUserUI3
        
        do {
            try await viewModel.joinRoom(code: roomCode, user: user)
            XCTFail("Should have thrown an error")
        } catch let error as JoinRoomError {
            XCTAssertEqual(error, .unableToFindRoom)
        } catch {
            XCTFail("Should have thrown NSError, but got \(error)")
        }
    }
    
    func testFetchJoinedRooms_withNonExistentUserID_returnsEmptyArray() async throws {
        // Given
        let userID = "non-existent-user"
        
        // When
        try await viewModel.fetchJoinedRooms(userID: userID)
        
        // Then
        XCTAssertEqual(viewModel.joinedRooms.count, 0)
    }
}
