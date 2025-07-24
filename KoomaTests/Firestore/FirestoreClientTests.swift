import XCTest
@testable import Kooma

//@MainActor
//final class FirestoreClientTests: XCTestCase {
//    
//    private var fakeClient: FakeFirestoreClient!
//    
//    override func setUp() {
//        super.setUp()
//        fakeClient = FakeFirestoreClient()
//    }
//    
//    override func tearDown() {
//        fakeClient.reset()
//        fakeClient = nil
//        super.tearDown()
//    }
//    
//    // MARK: - saveRoom Tests
//    
//    func testSaveRoom_Success() async throws {
//
//        let room = FixturesConstants.createSampleRoom()
//
//        try await fakeClient.saveRoom(room)
//
//        let myRooms = try await fakeClient.getMyRooms(forUserID: FixturesConstants.sampleUser1.id)
//        XCTAssertEqual(myRooms.count, 1)
//        XCTAssertEqual(myRooms.first?.code, room.code)
//    }
//    
//    func testSaveRoom_Failure() async {
//
//        let room = FixturesConstants.createSampleRoomWithNoID()
//        self.fakeClient.shouldThrowErrorOnSaveRoom = true
//        
//        do {
//            try await fakeClient.saveRoom(room)
//            XCTAssertTrue(fakeClient.shouldThrowErrorOnSaveRoom)
//            XCTFail("Should have thrown an error")
//        } catch {
//            XCTAssertNotNil(error)
//        }
//    }
//    
//    
//    // MARK: - joinRoom Tests
//    
//    func testJoinRoom_Success() async throws {
//
//        let room = FixturesConstants.createSampleRoom()
//        fakeClient.addRoom(room)
//        let newUser = FixturesConstants.sampleUser3
//
//        try await fakeClient.joinRoom(withCode: room.code, user: newUser)
//        
//        let joinedRooms = try await fakeClient.getJoinedRooms(forUserID: newUser.id)
//        XCTAssertEqual(joinedRooms.count, 1)
//        XCTAssertEqual(joinedRooms.first?.code, room.code)
//    }
//    
//    func testJoinRoom_RoomNotFound() async {
//        // Given
//        let user = FixturesConstants.sampleUser1
//        
//        // When/Then
//        do {
//            try await fakeClient.joinRoom(withCode: "INVALID", user: user)
//            XCTFail("Should have thrown an error")
//        } catch let error as NSError {
//            XCTAssertEqual(error.code, 404)
//        }
//    }
//    
//    func testJoinRoom_Failure() async {
//        // Given
//        let room = FixturesConstants.createSampleRoom()
//        fakeClient.addRoom(room)
//        fakeClient.shouldThrowErrorOnJoinRoom = true
//        
//        // When/Then
//        do {
//            try await fakeClient.joinRoom(withCode: room.code, user: FixturesConstants.sampleUser3)
//            XCTFail("Should have thrown an error")
//        } catch {
//            XCTAssertNotNil(error)
//        }
//    }
//    
//    // MARK: - leaveRoom Tests
//    
//    func testLeaveRoom_RegularMember() async throws {
//        // Given
//        let room = FixturesConstants.createSampleRoom()
//        fakeClient.addRoom(room)
//        let leavingUser = FixturesConstants.sampleUser2
//        
//        // When
//        try await fakeClient.leaveRoom(roomID: room.id!, user: leavingUser)
//        
//        // Then
//        let updatedRoom = try await fakeClient.getMyRooms(forUserID: FixturesConstants.sampleUser1.id).first
//        XCTAssertNotNil(updatedRoom)
//        XCTAssertFalse(updatedRoom!.members.contains { $0.id == leavingUser.id })
//        XCTAssertFalse(updatedRoom!.regularMembersID.contains(leavingUser.id))
//    }
//    
//    func testLeaveRoom_AdminTransfer() async throws {
//        // Given
//        let room = FixturesConstants.createSampleRoom()
//        fakeClient.addRoom(room)
//        let admin = FixturesConstants.sampleUser1
//        
//        // When
//        try await fakeClient.leaveRoom(roomID: room.id!, user: admin)
//        
//        // Then
//        let myRooms = try await fakeClient.getMyRooms(forUserID: admin.id)
//        XCTAssertEqual(myRooms.count, 0)
//        
//        let newAdminRooms = try await fakeClient.getMyRooms(forUserID: FixturesConstants.sampleUser2.id)
//        XCTAssertEqual(newAdminRooms.count, 1)
//        XCTAssertEqual(newAdminRooms.first?.administrator.id, FixturesConstants.sampleUser2.id)
//    }
//    
//    func testLeaveRoom_LastMemberDeletesRoom() async throws {
//        // Given
//        var room = FixturesConstants.createSampleRoom()
//        room.members = [FixturesConstants.sampleUser1]
//        room.regularMembersID = []
//        fakeClient.addRoom(room)
//        
//        // When
//        try await fakeClient.leaveRoom(roomID: room.id!, user: FixturesConstants.sampleUser1)
//        
//        // Then
//        let myRooms = try await fakeClient.getMyRooms(forUserID: FixturesConstants.sampleUser1.id)
//        XCTAssertEqual(myRooms.count, 0)
//    }
//    
//    // MARK: - deleteRoom Tests
//    
//    func testDeleteRoom_Success() async throws {
//        // Given
//        let room = FixturesConstants.createSampleRoom()
//        fakeClient.addRoom(room)
//        
//        // When
//        try await fakeClient.deleteRoom(withID: room.id!, byuserID: FixturesConstants.sampleUser1.id)
//        
//        // Then
//        let myRooms = try await fakeClient.getMyRooms(forUserID: FixturesConstants.sampleUser1.id)
//        XCTAssertEqual(myRooms.count, 0)
//    }
//    
//    func testDeleteRoom_NotAuthorized() async {
//        // Given
//        let room = FixturesConstants.createSampleRoom()
//        fakeClient.addRoom(room)
//        
//        // When/Then
//        do {
//            try await fakeClient.deleteRoom(withID: room.id!, byuserID: FixturesConstants.sampleUser2.id)
//            XCTFail("Should have thrown an error")
//        } catch let error as NSError {
//            XCTAssertEqual(error.code, 403)
//        }
//    }
//    
//    // MARK: - getMyRooms Tests
//    
//    func testGetMyRooms_Success() async throws {
//        // Given
//        let room1 = FixturesConstants.createSampleRoom(id: "room1", administrator: FixturesConstants.sampleUser1)
//        let room2 = FixturesConstants.createSampleRoom(id: "room2", administrator: FixturesConstants.sampleUser2)
//        fakeClient.addRoom(room1)
//        fakeClient.addRoom(room2)
//        
//        // When
//        let myRooms = try await fakeClient.getMyRooms(forUserID: FixturesConstants.sampleUser1.id)
//        
//        // Then
//        XCTAssertEqual(myRooms.count, 1)
//        XCTAssertEqual(myRooms.first?.id, "room1")
//    }
//    
//    func testGetMyRooms_Empty() async throws {
//        // When
//        let myRooms = try await fakeClient.getMyRooms(forUserID: FixturesConstants.sampleUser1.id)
//        
//        // Then
//        XCTAssertEqual(myRooms.count, 0)
//    }
//    
//    // MARK: - getJoinedRooms Tests
//    
//    func testGetJoinedRooms_Success() async throws {
//        // Given
//        let room = FixturesConstants.createSampleRoom()
//        fakeClient.addRoom(room)
//        
//        // When
//        let joinedRooms = try await fakeClient.getJoinedRooms(forUserID: FixturesConstants.sampleUser2.id)
//        
//        // Then
//        XCTAssertEqual(joinedRooms.count, 1)
//        XCTAssertEqual(joinedRooms.first?.id, room.id)
//    }
//    
//    // MARK: - updateVotes Tests
//    
//    func testUpdateVotes_AddVote() async throws {
//        // Given
//        let room = FixturesConstants.createSampleRoom()
//        fakeClient.addRoom(room)
//        
//        // When
//        try await fakeClient.updateVotes(
//            forRoomID: room.id!,
//            restaurantID: "restaurant2",
//            userID: FixturesConstants.sampleUser1.id,
//            action: .add
//        )
//        
//        // Then
//        let myRooms = try await fakeClient.getMyRooms(forUserID: FixturesConstants.sampleUser1.id)
//        let updatedRoom = myRooms.first!
//        XCTAssertTrue(updatedRoom.votes["restaurant2"]?.contains(FixturesConstants.sampleUser1.id) == true)
//    }
//    
//    func testUpdateVotes_RemoveVote() async throws {
//        // Given
//        let room = FixturesConstants.createSampleRoom()
//        fakeClient.addRoom(room)
//        
//        // When
//        try await fakeClient.updateVotes(
//            forRoomID: room.id!,
//            restaurantID: "restaurant1",
//            userID: FixturesConstants.sampleUser1.id,
//            action: .remove
//        )
//        
//        // Then
//        let myRooms = try await fakeClient.getMyRooms(forUserID: FixturesConstants.sampleUser1.id)
//        let updatedRoom = myRooms.first!
//        XCTAssertFalse(updatedRoom.votes["restaurant1"]?.contains(FixturesConstants.sampleUser1.id) == true)
//    }
//    
//    // MARK: - Listener Tests
//    
//    func testListenToMyRooms() async throws {
//        // Given
//        let expectation = XCTestExpectation(description: "MyRooms listener receives updates")
//        var receivedRooms: [[RoomDomain]] = []
//        
//        // When
//        let stream = fakeClient.listenToMyRooms(forUserID: FixturesConstants.sampleUser1.id)
//        
//        Task {
//            do {
//                for try await rooms in stream {
//                    receivedRooms.append(rooms)
//                    if receivedRooms.count == 2 {
//                        expectation.fulfill()
//                        break
//                    }
//                }
//            } catch {
//                XCTFail("Stream threw an error: \(error)")
//            }
//        }
//        
//        // Add a room after a short delay
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            Task {
//                let room = FixturesConstants.createSampleRoom()
//                try await self.fakeClient.saveRoom(room)
//            }
//        }
//        
//        await fulfillment(of: [expectation], timeout: 2.0)
//        
//        // Then
//        XCTAssertEqual(receivedRooms.count, 2)
//        XCTAssertEqual(receivedRooms[0].count, 0) // Initial empty state
//        XCTAssertEqual(receivedRooms[1].count, 1) // After adding room
//    }
//    
//    func testListenToRoom() async throws {
//        // Given
//        let room = FixturesConstants.createSampleRoom()
//        fakeClient.addRoom(room)
//        
//        let expectation = XCTestExpectation(description: "Room listener receives updates")
//        var receivedRooms: [RoomDomain] = []
//        
//        // When
//        let stream = fakeClient.listenToRoom(withID: room.id!)
//        
//        Task {
//            do {
//                for try await updatedRoom in stream {
//                    receivedRooms.append(updatedRoom)
//                    if receivedRooms.count == 2 {
//                        expectation.fulfill()
//                        break
//                    }
//                }
//            } catch {
//                XCTFail("Stream threw an error: \(error)")
//            }
//        }
//        
//        // Update votes after a short delay
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            Task {
//                try await self.fakeClient.updateVotes(
//                    forRoomID: room.id!,
//                    restaurantID: "restaurant2",
//                    userID: FixturesConstants.sampleUser1.id,
//                    action: .add
//                )
//            }
//        }
//        
//        await fulfillment(of: [expectation], timeout: 2.0)
//        
//        // Then
//        XCTAssertEqual(receivedRooms.count, 2)
//        XCTAssertEqual(receivedRooms[0].votes["restaurant2"]?.count ?? 0, 0) // Initial state
//        XCTAssertEqual(receivedRooms[1].votes["restaurant2"]?.count ?? 0, 1) // After vote update
//    }
//}
