
import Foundation

struct RoomUI: Identifiable, Codable, Sendable {
	let id: UUID
	var name: String?
	var administrator: UserUI
	var address: String?
	var members: [UserUI] = []
	var restaurants: [RestaurantUI]?
	var image: String

	init(id: UUID = UUID(), name: String? = nil, administrator: UserUI) {
		self.id = UUID()
		self.name = name
		self.administrator = administrator
		self.members = [self.administrator]
		self.image = [
			"RoomIcon-1",
			"RoomIcon-2",
			"RoomIcon-3"
		].randomElement()!

	}
}
