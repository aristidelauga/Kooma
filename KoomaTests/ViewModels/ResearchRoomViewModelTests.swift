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
    
    func testJoinRoom_whenRoomNotFound_throwsUnableToFindRoomError() async {
        // Given
        let roomCode = "INVALID"
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
    
    func testJoinRoom_withEmptyCode_throwsUnableToFindRoomError() async {
        // Given
        let roomCode = ""
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
    
    func testJoinRoom_withWhitespaceCode_throwsUnableToFindRoomError() async {
        // Given
        let roomCode = "   "
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
    
    func testJoinRoom_whenClientThrowsError_throwsUnableToFindRoomError() async {
        // Given
        let roomCode = "ABC123"
        let user = FixturesConstants.sampleUserUI3
        mockClient.shouldThrowErrorOnJoinRoom = true
        
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
    
    // MARK: - fetchJoinedRooms Tests
    
    func testFetchJoinedRooms_withValidUserID_succeeds() async throws {
        // Given
        let userID = FixturesConstants.sampleUserUI2.id
        let room = FixturesConstants.createSampleRoom()
        mockClient.addRoom(room)
        
        // When
        try await viewModel.fetchJoinedRooms(userID: userID)
        
        // Then
        XCTAssertEqual(viewModel.joinedRooms.count, 1)
        XCTAssertEqual(viewModel.joinedRooms.first?.id, room.id)
    }
    
    func testFetchJoinedRooms_whenClientThrowsError_propagatesError() async {
        // Given
        let userID = FixturesConstants.sampleUserUI2.id
        mockClient.shouldThrowErrorOnGetJoinedRooms = true
        
        // When/Then
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
        
        // Then
        let joinedRooms = try await mockClient.getJoinedRooms(forUserID: user.id)
        XCTAssertEqual(joinedRooms.count, 1)
        XCTAssertEqual(joinedRooms.first?.code, roomCode)
    }
    
    func testJoinRoomFlow_whenAlreadyJoined_preventsJoining() async throws {
        // Given
        let roomCode = "ABC123"
        let user = FixturesConstants.sampleUserUI3
        let room = FixturesConstants.createSampleRoom(code: roomCode)
        mockClient.addRoom(room)
        
        // Join room first
        try await mockClient.joinRoom(withCode: roomCode, user: user.toDomain())
        
        // Fetch joined rooms to populate viewModel
        try await viewModel.fetchJoinedRooms(userID: user.id)
        
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
    
    // MARK: - Edge Cases
    
    func testJoinRoom_withSpecialCharactersInCode_handlesCorrectly() async {
        // Given
        let roomCode = "ABC-123"
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
    
    func testFetchJoinedRooms_withNonExistentUserID_returnsEmptyArray() async throws {
        // Given
        let userID = "non-existent-user"
        
        // When
        try await viewModel.fetchJoinedRooms(userID: userID)
        
        // Then
        XCTAssertEqual(viewModel.joinedRooms.count, 0)
    }
}
