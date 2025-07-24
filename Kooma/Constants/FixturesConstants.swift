
import SwiftUI
import MapKit

final class FixturesConstants {
    static let sampleUser1 = UserDomain(id: "user1", name: "Alice")
    static let sampleUser2 = UserDomain(id: "user2", name: "Bob")
    static let sampleUser3 = UserDomain(id: "user3", name: "Charlie")
    
    static let samplePlacemark = CodablePlacemark(
        latitude: 48.8566,
        longitude: 2.3522,
        name: "Restaurant Test",
        country: "France",
        postalCode: "75001",
        locality: "Paris",
        thoroughfare: "Rue de la Paix",
        subThoroughfare: "10"
    )
    
    static let sampleRestaurant1 = RestaurantDomain(
        id: "restaurant1",
        name: "Chez Alice",
        phoneNumber: "+33123456789",
        address: "10 Rue de la Paix, 75001 Paris, France",
        placemark: samplePlacemark,
        url: "https://example.com/restaurant1"
    )
    
    static let sampleRestaurant2 = RestaurantDomain(
        id: "restaurant2",
        name: "Le Bistrot",
        phoneNumber: "+33987654321",
        address: "20 Avenue des Champs, 75008 Paris, France",
        placemark: samplePlacemark,
        url: "https://example.com/restaurant2"
    )
    
    static func createSampleRoom(
        id: String = "room1",
        code: String = "ABC123",
        name: String? = "Test Room",
        administrator: UserDomain = sampleUser1,
        address: String = "Paris, France",
        members: [UserDomain] = [sampleUser1, sampleUser2],
        regularMembersID: [String] = ["user2"],
        restaurants: [RestaurantDomain] = [sampleRestaurant1],
        votes: [String: [String]] = ["restaurant1": ["user1", "user2"]],
        image: String = "RoomOne"
    ) -> RoomDomain {
        var room = RoomDomain(
            code: code,
            name: name,
            administrator: administrator,
            address: address,
            members: members,
            regularMembersID: regularMembersID,
            restaurants: restaurants,
            votes: votes,
            image: image
        )
        room.id = id
        return room
    }
    
    static func createSampleRoomWithNoID(
        id: String? = nil,
        code: String = "ABC123",
        name: String? = "Test Room",
        administrator: UserDomain = sampleUser1,
        address: String = "Paris, France",
        members: [UserDomain] = [sampleUser1, sampleUser2],
        regularMembersID: [String] = ["user2"],
        restaurants: [RestaurantDomain] = [sampleRestaurant1],
        votes: [String: [String]] = ["restaurant1": ["user1", "user2"]],
        image: String = "RoomOne"
    ) -> RoomDomain {
        var room = RoomDomain(
            code: code,
            name: name,
            administrator: administrator,
            address: address,
            members: members,
            regularMembersID: regularMembersID,
            restaurants: restaurants,
            votes: votes,
            image: image
        )
        room.id = id
        return room
    }
}

extension FixturesConstants {
    static let sampleUserUI1 = UserUI(id: "user1", name: "Alice")
    static let sampleUserUI2 = UserUI(id: "user2", name: "Bob")
    static let sampleUserUI3 = UserUI(id: "user3", name: "Charlie")
    
    static let sampleRestaurantUI1 = RestaurantUI(
        id: "restaurant1",
        name: "Chez Alice",
        phoneNumber: "+33123456789",
        address: "10 Rue de la Paix, 75001 Paris, France",
        placemark: samplePlacemark,
        url: "https://example.com/restaurant1"
    )
    
    static let sampleRestaurantUI2 = RestaurantUI(
        id: "restaurant2",
        name: "Le Bistrot",
        phoneNumber: "+33987654321",
        address: "20 Avenue des Champs, 75008 Paris, France",
        placemark: samplePlacemark,
        url: "https://example.com/restaurant2"
    )
    
    static func createSampleRoomUI(
        id: String? = "id1",
        name: String? = "Test Room",
        administrator: UserUI = sampleUserUI1,
        address: String? = "Paris, France",
        members: [UserUI] = [sampleUserUI1, sampleUserUI2],
        regularMembersID: [String] = ["user2"],
        restaurants: [RestaurantUI] = [sampleRestaurantUI1],
        votes: [String: [String]] = ["restaurant1": ["user1", "user2"]],
        image: String? = "RoomOne"
    ) -> RoomUI {
        return RoomUI(
            id: id,
            hostID: administrator.id,
            code: RoomUI.generateCode(),
            name: name,
            administrator: administrator,
            address: address,
            members: members,
            restaurants: restaurants,
            votes: votes,
            image: image ?? "RoomOne"
        )
    }
    
    static func createSampleRoomUIWithNoID(
        id: String? = nil,
        name: String? = "Test Room",
        administrator: UserUI = sampleUserUI1,
        address: String? = "Paris, France",
        members: [UserUI] = [sampleUserUI1, sampleUserUI2],
        regularMembersID: [String] = ["user2"],
        restaurants: [RestaurantUI] = [sampleRestaurantUI1],
        votes: [String: [String]] = ["restaurant1": ["user1", "user2"]],
        image: String? = "RoomOne"
    ) -> RoomUI {
        return RoomUI(
            id: id,
            hostID: administrator.id,
            code: RoomUI.generateCode(),
            name: name,
            administrator: administrator,
            address: address,
            members: members,
            restaurants: restaurants,
            votes: votes,
            image: image ?? "RoomOne"
        )
    }
}
