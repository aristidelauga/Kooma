import XCTest
@testable import Kooma

final class ModelConvertibleTests: XCTestCase {
    
    // MARK: - User Conversion Tests
    
    func testUserUIToUserDomain() throws {
        // Given
        let userUI = FixturesConstants.sampleUserUI1
        
        // When
        let userDomain = try userUI.toDomain()
        
        // Then
        XCTAssertEqual(userUI.id, userDomain.id)
        XCTAssertEqual(userUI.name, userDomain.name)
    }
    
    func testUserDomainToUserUI() {
        // Given
        let userDomain = FixturesConstants.sampleUser1Domain
        
        // When
        let userUI = userDomain.toUI()
        
        // Then
        XCTAssertEqual(userDomain.id, userUI.id)
        XCTAssertEqual(userDomain.name, userUI.name)
    }
    
    // MARK: - Restaurant Conversion Tests
    
    func testRestaurantDTOToRestaurantUI() throws {
        // Given
        let restaurantDTO = RestaurantDTO(
            id: "restaurant1",
            name: "Le Procope",
            phoneNumber: "0123456789",
            placemark: FixturesConstants.parisPlacemark,
            url: "https://www.procope.com/"
        )
        
        // When
        let restaurantUI = try restaurantDTO.toUI()
        
        // Then
        XCTAssertEqual(restaurantDTO.id, restaurantUI.id)
        XCTAssertEqual(restaurantDTO.name, restaurantUI.name)
        XCTAssertEqual(restaurantDTO.phoneNumber, restaurantUI.phoneNumber)
        XCTAssertEqual(restaurantDTO.url, restaurantUI.url)
        XCTAssertTrue(restaurantUI.address.contains("Tour Eiffel"))
    }
    
    func testRestaurantUIToRestaurantDomain() throws {
        // Given
        let restaurantUI = FixturesConstants.sampleRestaurantUI1
        
        // When
        let restaurantDomain = try restaurantUI.toDomain()
        
        // Then
        XCTAssertEqual(restaurantUI.id, restaurantDomain.id)
        XCTAssertEqual(restaurantUI.name, restaurantDomain.name)
        XCTAssertEqual(restaurantUI.phoneNumber, restaurantDomain.phoneNumber)
        XCTAssertEqual(restaurantUI.address, restaurantDomain.address)
        XCTAssertEqual(restaurantUI.url, restaurantDomain.url)
    }
    
    func testRestaurantDomainToRestaurantUI() {
        // Given
        let restaurantDomain = FixturesConstants.sampleRestaurant1
        
        // When
        let restaurantUI = restaurantDomain.toUI()
        
        // Then
        XCTAssertEqual(restaurantDomain.id, restaurantUI.id)
        XCTAssertEqual(restaurantDomain.name, restaurantUI.name)
        XCTAssertEqual(restaurantDomain.phoneNumber, restaurantUI.phoneNumber)
        XCTAssertEqual(restaurantDomain.address, restaurantUI.address)
        XCTAssertEqual(restaurantDomain.url, restaurantUI.url)
    }
    
    // MARK: - Room Conversion Tests
    
    func testRoomUIToRoomDomain() throws {
        // Given
        let roomUI = FixturesConstants.createSampleRoomUI()
        
        // When
        let roomDomain = try roomUI.toDomain()
        
        // Then
        XCTAssertEqual(roomUI.id, roomDomain.id)
        XCTAssertEqual(roomUI.code, roomDomain.code)
        XCTAssertEqual(roomUI.name, roomDomain.name)
        XCTAssertEqual(roomUI.administrator.id, roomDomain.administrator.id)
        XCTAssertEqual(roomUI.address, roomDomain.address)
        XCTAssertEqual(roomUI.members.count, roomDomain.members.count)
        XCTAssertEqual(roomUI.restaurants.count, roomDomain.restaurants.count)
        XCTAssertEqual(roomUI.votes.count, roomDomain.votes.count)
        XCTAssertEqual(roomUI.image, roomDomain.image)
    }
    
    func testRoomDomainToRoomUI() {
        // Given
        let roomDomain = FixturesConstants.createSampleRoom()
        
        // When
        let roomUI = roomDomain.toUI()
        
        // Then
        XCTAssertEqual(roomDomain.id, roomUI.id)
        XCTAssertEqual(roomDomain.code, roomUI.code)
        XCTAssertEqual(roomDomain.name, roomUI.name)
        XCTAssertEqual(roomDomain.administrator.id, roomUI.administrator.id)
        XCTAssertEqual(roomDomain.address, roomUI.address)
        XCTAssertEqual(roomDomain.members.count, roomUI.members.count)
        XCTAssertEqual(roomDomain.restaurants.count, roomUI.restaurants.count)
        XCTAssertEqual(roomDomain.votes.count, roomUI.votes.count)
        XCTAssertEqual(roomDomain.image, roomUI.image)
    }
}
