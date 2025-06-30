import Foundation
@preconcurrency import FirebaseFirestore

struct RoomDTO: Identifiable, Codable, Sendable {
	@DocumentID var id: String?
	var hostID: String {
		administrator.id ?? ""
	}
	var name: String
	var administrator: UserDTO
	var address: String
	var members: [UserDTO]
	var restaurants: [RestaurantDTO]
}
