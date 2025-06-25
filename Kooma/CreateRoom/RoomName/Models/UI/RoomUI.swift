
import Foundation

struct RoomUI: Identifiable, Codable, Sendable {
	let id: String
	var name: String?
	var administrator: UserUI
	var address: String?
	var members: [UserUI] = []
	var restaurants: [RestaurantUI]?
	var image: String

	init(id: String = RoomUI.generateCode(), name: String? = nil, administrator: UserUI) {
		self.id = id
		self.name = name
		self.administrator = administrator
		self.members = [self.administrator]
		self.image = [
			"RoomIcon-1",
			"RoomIcon-2",
			"RoomIcon-3"
		].randomElement()!

	}

	static func generateCode(length: Int = 6) -> String {
		let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		return String((0..<length).compactMap { _ in characters.randomElement() })
	}
}
