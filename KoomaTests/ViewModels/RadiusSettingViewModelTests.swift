import XCTest
import MapKit
@testable import Kooma

@MainActor
final class RadiusSettingViewModelTests: XCTestCase {

    var mockAPI: MockRestaurantAPI!
    var mockClient: FirestoreClientInterface!
    var service: FirestoreServiceInterface!
    var viewModel: RadiusSettingViewModel!
    var room: RoomUI!

    override func setUp() {
        super.setUp()
        mockAPI = MockRestaurantAPI()
        mockClient = FakeFirestoreClient()
        service = FirestoreService(client: mockClient)
        room = FixturesConstants.createSampleRoomUIWithNoRestaurants()
        room.address = FixturesConstants.sampleAddress
        viewModel = RadiusSettingViewModel(restaurantAPI: mockAPI, service: service, room: room)
    }

    override func tearDown() {
        viewModel = nil
        mockAPI = nil
        service = nil
        room = nil
        super.tearDown()
    }

    func testInit_setsDependenciesAndRoom() {
        XCTAssertTrue(viewModel.room == room)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testSearchRestaurants_successful() async throws {
        mockAPI.coordinateToReturn = CLLocationCoordinate2D(latitude: 1, longitude: 2)
        let dto = RestaurantDTO(id: "id", name: "R", phoneNumber: "123", placemark: FixturesConstants.parisPlacemark, url: "u")
        mockAPI.searchResults = [dto]
        viewModel.room.restaurants = []
        try await viewModel.searchRestaurants(within: 2)
        XCTAssertEqual(viewModel.region.center.latitude, 1)
        XCTAssertEqual(viewModel.region.center.longitude, 2)
        XCTAssertEqual(viewModel.room.restaurants.count, 1)
        XCTAssertEqual(viewModel.room.restaurants.first?.name, "R")
        XCTAssertFalse(viewModel.isLoading)
    }

    func testSearchRestaurants_missingAddress_throws() async {
        viewModel.room.address = nil
        do {
            try await viewModel.searchRestaurants(within: 1)
            XCTFail("Should throw")
        } catch {
            XCTAssertEqual((error as NSError).code, 4)
        }
        XCTAssertFalse(viewModel.isLoading)
    }

    func testSearchRestaurants_emptyAddress_throws() async {
        viewModel.room.address = ""
        do {
            try await viewModel.searchRestaurants(within: 1)
            XCTFail("Should throw")
        } catch {
            XCTAssertEqual((error as NSError).code, 4)
        }
        XCTAssertFalse(viewModel.isLoading)
    }

    func testSearchRestaurants_coordinateError_throwsCustom() async {
        mockAPI.coordinateError = NSError(domain: "Test", code: 99)
        do {
            try await viewModel.searchRestaurants(within: 1)
            XCTFail("Should throw")
        } catch {
            XCTAssertEqual((error as NSError).code, 14)
        }
        XCTAssertFalse(viewModel.isLoading)
    }

    func testSearchRestaurants_searchError_throwsCustom() async {
        mockAPI.coordinateToReturn = CLLocationCoordinate2D(latitude: 1, longitude: 2)
        mockAPI.searchError = NSError(domain: "Test", code: 88)
        do {
            try await viewModel.searchRestaurants(within: 1)
            XCTFail("Should throw")
        } catch {
            XCTAssertEqual((error as NSError).code, 14)
        }
        XCTAssertFalse(viewModel.isLoading)
    }

    func testSearchRestaurants_noResults_doesNotCrash() async throws {
        mockAPI.coordinateToReturn = CLLocationCoordinate2D(latitude: 1, longitude: 2)
        mockAPI.searchResults = nil
        try await viewModel.searchRestaurants(within: 1)
        XCTAssertEqual(viewModel.room.restaurants.count, 0)
        XCTAssertFalse(viewModel.isLoading)
    }
}
