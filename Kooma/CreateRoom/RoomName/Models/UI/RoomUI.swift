
import Foundation
@preconcurrency import FirebaseFirestore

struct RoomUI: Identifiable, Codable, Sendable {
	@DocumentID var id: String?
    var hostID: String {
        administrator.id
    }
    var code: String?
	var name: String?
	var administrator: UserUI
	var address: String?
	var members: [UserUI]? = []
	var restaurants: [RestaurantUI]?
	var image: String

	init(id: String = RoomUI.generateCode(), name: String? = nil, administrator: UserUI) {
		self.id = id
		self.name = name
		self.administrator = administrator
		self.members = [self.administrator]
		self.image = [
            "RoomOne",
            "RoomTwo",
            "RoomThree",
            "RoomFour",
            "RoomFive",
            "RoomSix",
            "RoomSeven"
        ].randomElement()!

	}
    
    init(
        id: String?,
        name: String?,
        administrator: UserUI,
        address: String?,
        members: [UserUI],
        restaurants: [RestaurantUI]
    ) {
        self.id = id
        self.code = RoomUI.generateCode()
        self.name = name
        self.administrator = administrator
        self.address = address
        self.members = members
        self.restaurants = restaurants
        self.image = [
            "RoomOne",
            "RoomTwo",
            "RoomThree",
            "RoomFour",
            "RoomFive",
            "RoomSix",
            "RoomSeven"
        ].randomElement()!
    }

	static func generateCode(length: Int = 6) -> String {
		let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		return String((0..<length).compactMap { _ in characters.randomElement() })
	}
}
