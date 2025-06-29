import Foundation

struct RoomDTO: Identifiable, Codable, Sendable {
	let id: String
	var hostID: UUID {
		administrator.id
	}
	var name: String
	var administrator: UserDTO
	var address: String
	var members: [UserDTO]
	var restaurants: [RestaurantDTO]
}
