
import Foundation

struct RoomUI: Identifiable, Codable, Sendable {
	let id: UUID
	var name: String?
	var administrator: UserUI?
	var address: String?
	var members: [UserUI]?
	var restaurants: [RestaurantUI]?

	init(id: UUID = UUID(), name: String? = nil) {
		self.id = UUID()
		self.name = name
	}
}
