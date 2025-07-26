import XCTest
import MapKit
@testable import Kooma

@MainActor
final class SearchAddressViewModelTests: XCTestCase {

    var viewModel: SearchAddressViewModel!
    var mockCompleter: MockLocalSearchCompleter!

    override func setUp() {
        super.setUp()
        mockCompleter = MockLocalSearchCompleter()
        viewModel = SearchAddressViewModel(localSearchCompleter: mockCompleter)
    }

    override func tearDown() {
        viewModel = nil
        mockCompleter = nil
        super.tearDown()
    }

    func testDefaultInit_setsUpCompleterAndEmptyResults() {
        XCTAssertTrue(viewModel.results.isEmpty)
        XCTAssertEqual(viewModel.searchableText, "")
        XCTAssertNil(viewModel.room)
        XCTAssertTrue(viewModel.localSearchCompleter.delegate === viewModel)
    }

    func testInitWithRoom_setsRoomAndCompleter() {
        let room = FixturesConstants.createSampleRoomUI()
        viewModel = SearchAddressViewModel(room: room, localSearchCompleter: mockCompleter)
        XCTAssertEqual(viewModel.room, room)
        XCTAssertTrue(viewModel.localSearchCompleter.delegate === viewModel)
        XCTAssertTrue(viewModel.results.isEmpty)
    }

    func testSearchAddress_emptyString_doesNothing() {
        viewModel.searchAddress("")
        XCTAssertNil(mockCompleter.setQueryFragment)
    }

    func testSearchAddress_nonEmpty_setsQueryFragment() {
        viewModel.searchAddress("Paris")
        XCTAssertEqual(mockCompleter.setQueryFragment, "Paris")
    }

    func testFillSearchText_setsSearchableText() {
        viewModel.fillSearchText(result: "Tour Eiffel")
        XCTAssertEqual(viewModel.searchableText, "Tour Eiffel")
    }

    func testAssignAddressToRoom_setsRoomAddress() {
        let room = FixturesConstants.createSampleRoomUI()
        viewModel = SearchAddressViewModel(room: room, localSearchCompleter: mockCompleter)
        viewModel.searchableText = "Champ de Mars"
        viewModel.assignAddressToRoom()
        XCTAssertEqual(viewModel.room?.address, "Champ de Mars")
    }

    func testMockLocalSearchCompleter_queryFragmentGetter_returnsSetValueOrEmptyString() {
        let mock = MockLocalSearchCompleter()
        // Default should be empty string
        XCTAssertEqual(mock.queryFragment, "")
        // When setQueryFragment is set
        mock.setQueryFragment = "Paris"
        XCTAssertEqual(mock.queryFragment, "Paris")
        // When setQueryFragment is set to nil again
        mock.setQueryFragment = nil
        XCTAssertEqual(mock.queryFragment, "")
    }
}

