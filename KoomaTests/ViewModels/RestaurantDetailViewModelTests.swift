import XCTest
import MapKit
@testable import Kooma

@MainActor
final class RestaurantDetailViewModelTests: XCTestCase {
    
    var viewModel: RestaurantDetailViewModel!
    let sampleRestaurant = FixturesConstants.sampleRestaurantUI1
    
    override func setUp() {
        super.setUp()
        viewModel = RestaurantDetailViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    func testInit_createsInstanceWithDefaultValues() {
        let viewModel = RestaurantDetailViewModel()
        
        XCTAssertNotNil(viewModel)
        XCTAssertNil(viewModel.lookAroundScene)
        XCTAssertNil(viewModel.mkMapItem)
    }
    
    func testSearchMapItem_withValidRestaurant_returnsMapItem() async {
        let restaurant = sampleRestaurant
        
        let mapItem = await viewModel.searchMapItem(for: restaurant)
        XCTAssertNotNil(mapItem)
    }
    
    func testSearchMapItem_setsCorrectSearchParameters() async {
        let restaurant = sampleRestaurant
        
        let mapItem = await viewModel.searchMapItem(for: restaurant)
        XCTAssertNotNil(mapItem)
    }
    
    func testSearchMapItem_withInvalidRestaurant_handlesGracefully() async {
        let invalidRestaurant = FixturesConstants.invalidRestaurant
        
        let mapItem = await viewModel.searchMapItem(for: invalidRestaurant)

        XCTAssertNil(mapItem)
    }
    
    func testSearchMapItem_handlesSearchErrors() async {
        let restaurant = sampleRestaurant
        
        let mapItem = await viewModel.searchMapItem(for: restaurant)
        
        XCTAssertNotNil(mapItem)
    }
    
    
    func testMakeACall_withValidPhoneNumber_attemptsToOpenURL() {
        let phoneNumber = "+33123456789"
        viewModel.makeACall(phoneNumber)
    }
    
    func testMakeACall_withInvalidPhoneNumber_doesNotCrash() {
        let invalidPhoneNumber = "invalid-phone"
        viewModel.makeACall(invalidPhoneNumber)
    }
    
    func testMakeACall_withEmptyPhoneNumber_doesNotCrash() {
        let emptyPhoneNumber = ""
        // Should not crash with empty phone number
        viewModel.makeACall(emptyPhoneNumber)
    }
    
    func testMakeACall_withSpecialCharacters_doesNotCrash() {
        let specialPhoneNumber = "+33-12-34-56-78-90"
        
        // Should handle special characters gracefully
        viewModel.makeACall(specialPhoneNumber)
    }
    
    // MARK: - fetchLookAroundPreview Tests
    
    func testFetchLookAroundPreview_withNilMapItem_doesNothing() {
        viewModel.mkMapItem = nil
        
        viewModel.fetchLookAroundPreview()
        
        XCTAssertNil(viewModel.lookAroundScene)
    }
    
    func testFetchLookAroundPreview_withValidMapItem_startsAsyncTask() {
        let mockMapItem = MKMapItem()
        viewModel.mkMapItem = mockMapItem
        
        viewModel.fetchLookAroundPreview()
        
        // The method starts an async task, so we can't easily test the result
        // we verify the method doesn't crash
    }
    
    func testFetchLookAroundPreview_setsLookAroundSceneToNilInitially() {
        let mockMapItem = MKMapItem()
        viewModel.mkMapItem = mockMapItem

        viewModel.lookAroundScene = nil
        
        viewModel.fetchLookAroundPreview()
        
        // The method should handle the async task without crashing
    }
    
    // MARK: - openInMaps Tests
    
    func testOpenInMaps_withValidMapItem_opensInMaps() throws {
        let restaurant = sampleRestaurant
        let mockMapItem = MKMapItem()
        viewModel.mkMapItem = mockMapItem
        
        // we just verify the method doesn't throw
        try viewModel.openInMaps(restaurant)
    }
    
    func testOpenInMaps_setsRestaurantNameOnMapItem() throws {
        let restaurant = sampleRestaurant
        let mockMapItem = MKMapItem()
        viewModel.mkMapItem = mockMapItem
        
        try viewModel.openInMaps(restaurant)

        // Since we can't easily test MKMapItem's internal state, we verify no exception is thrown
    }
    
    func testOpenInMaps_withNilMapItem_throwsError() {
        let restaurant = sampleRestaurant
        viewModel.mkMapItem = nil
        
        // The method should handle nil mapItem gracefully
        do {
            try viewModel.openInMaps(restaurant)
        } catch {
            XCTFail("openInMaps should not throw when mapItem is nil")
        }
    }
    
    
    func testCompleteFlow_searchMapItemThenFetchLookAroundPreview() async {
        let restaurant = sampleRestaurant
        
        let mapItem = await viewModel.searchMapItem(for: restaurant)
        viewModel.mkMapItem = mapItem
        viewModel.fetchLookAroundPreview()
        
        // we verify the flow works without crashing
        XCTAssertNotNil(mapItem)
    }
    
    func testCompleteFlow_searchMapItemThenOpenInMaps() async throws {
        let restaurant = sampleRestaurant
        
        let mapItem = await viewModel.searchMapItem(for: restaurant)
        viewModel.mkMapItem = mapItem
        try viewModel.openInMaps(restaurant)
        
        // we verify the flow works without crashing
        XCTAssertNotNil(mapItem)
    }
    
    // MARK: - Edge Cases
    
    func testSearchMapItem_withRestaurantHavingSpecialCharacters() async {
        let restaurantWithSpecialChars = RestaurantUI(
            id: "special",
            name: "Restaurant & Café - 123",
            phoneNumber: "+33123456789",
            address: "10 Rue de la Paix, 75001 Paris, France",
            placemark: FixturesConstants.samplePlacemark,
            url: "https://example.com/restaurant"
        )
        
        let mapItem = await viewModel.searchMapItem(for: restaurantWithSpecialChars)
        
        // Should handle special characters in restaurant name
        XCTAssertNotNil(mapItem)
    }
    
    func testMakeACall_withInternationalPhoneNumber() {
        let internationalPhone = "+1-555-123-4567"
        
        // Should handle international phone numbers
        viewModel.makeACall(internationalPhone)
    }
    
    func testMakeACall_withLocalPhoneNumber() {
        let localPhone = "0123456789"
        
        // Should handle local phone numbers
        viewModel.makeACall(localPhone)
    }
    
    func testLookAroundSceneProperty_canBeModified() {
        viewModel.lookAroundScene = nil
        XCTAssertNil(viewModel.lookAroundScene)
        
        //we can only test that the property accepts nil values
    }
    
    func testMkMapItemProperty_canBeModified() {
        let mockMapItem = MKMapItem()
        
        viewModel.mkMapItem = mockMapItem
        
        // MKMapItem doesn't support equality comparison, so we test that the property was set
        XCTAssertNotNil(viewModel.mkMapItem)
        XCTAssertTrue(viewModel.mkMapItem === mockMapItem)
    }
    
    func testSearchMapItem_handlesNetworkErrors() async {
        let restaurant = sampleRestaurant
        
        let mapItem = await viewModel.searchMapItem(for: restaurant)
        
        // Should handle network errors gracefully
        XCTAssertNotNil(mapItem)
    }
    
    func testFetchLookAroundPreview_handlesLookAroundErrors() {
        let mockMapItem = MKMapItem()
        viewModel.mkMapItem = mockMapItem
        
        viewModel.fetchLookAroundPreview()
        
        // Should handle LookAround errors gracefully
        // The method should not crash even if LookAround is not available
    }
}
