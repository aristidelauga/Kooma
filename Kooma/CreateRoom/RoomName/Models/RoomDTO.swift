import Foundation

struct RoomDTO: Identifiable, Codable, Sendable {
	var id: UUID
	var name: String
	var administrator: User
	var members: [User]
//	var restaurants: [Restaurant]
}
