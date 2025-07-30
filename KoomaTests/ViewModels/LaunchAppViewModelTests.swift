import XCTest
@testable import Kooma

@MainActor
final class LaunchAppViewModelTests: XCTestCase {
    var fakeClient: FakeFirestoreClient!
    var service: FirestoreService!
    var viewModel: LaunchAppViewModel!

    override func setUp() {
        super.setUp()
        fakeClient = FakeFirestoreClient()
        service = FirestoreService(client: fakeClient)
        viewModel = LaunchAppViewModel(service: service)
    }

    override func tearDown() {
        fakeClient.reset()
        viewModel = nil
        service = nil
        fakeClient = nil
        super.tearDown()
    }

    func testGetMyRoomsConverted_success() async throws {

        let room1 = FixturesConstants.createSampleRoom(id: "room1", administrator: FixturesConstants.sampleUser1Domain)
        let room2 = FixturesConstants.createSampleRoom(id: "room2", administrator: FixturesConstants.sampleUser2Domain)
        fakeClient.addRoom(room1)
        fakeClient.addRoom(room2)
        
        try await viewModel.getMyRoomsConverted(userID: FixturesConstants.sampleUser1Domain.id)

        XCTAssertEqual(viewModel.myRooms.count, 1)
        let expectedRoom = room1.toUI()
        XCTAssertEqual(viewModel.myRooms.first?.id, expectedRoom.id)
        XCTAssertEqual(viewModel.myRooms.first?.administrator.id, expectedRoom.administrator.id)
    }

    func testGetMyRoomsConverted_empty() async throws {

        try await viewModel.getMyRoomsConverted(userID: FixturesConstants.sampleUser1Domain.id)

        XCTAssertEqual(viewModel.myRooms.count, 0)
    }

    func testGetMyRoomsConverted_error() async {

        fakeClient.shouldThrowErrorOnGetMyRooms = true

        do {
            try await viewModel.getMyRoomsConverted(userID: FixturesConstants.sampleUser1Domain.id)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testGetJoinedRoomsConverted_success() async throws {

        let room = FixturesConstants.createSampleRoom()
        fakeClient.addRoom(room)

        try await viewModel.getJoinedRoomsConverted(userID: FixturesConstants.sampleUser2Domain.id)

        XCTAssertEqual(viewModel.joinedRooms.count, 1)
        let expectedRoom = room.toUI()
        XCTAssertEqual(viewModel.joinedRooms.first?.id, expectedRoom.id)
        XCTAssertEqual(viewModel.joinedRooms.first?.administrator.id, expectedRoom.administrator.id)
    }

    func testGetJoinedRoomsConverted_empty() async throws {

        try await viewModel.getJoinedRoomsConverted(userID: FixturesConstants.sampleUser1Domain.id)

        XCTAssertEqual(viewModel.joinedRooms.count, 0)
    }

    func testGetJoinedRoomsConverted_error() async {

        fakeClient.shouldThrowErrorOnGetJoinedRooms = true

        do {
            try await viewModel.getJoinedRoomsConverted(userID: FixturesConstants.sampleUser1Domain.id)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
