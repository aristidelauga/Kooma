import Foundation
@preconcurrency import FirebaseFirestore

struct RoomDTO: Identifiable, Codable, Sendable {
	@DocumentID var id: String? = nil
	var hostID: String {
		administrator.id ?? ""
	}
	var name: String
	var administrator: UserDTO
	var address: String
	var members: [UserDTO]
	var restaurants: [RestaurantDTO]
}

extension RoomDTO: UIModelConvertible {
    func toUI() throws -> RoomUI {
        RoomUI(
            id: self.id ?? "",
            name: self.name,
            administrator: try self.administrator.toUI(),
            address: self.address,
            members: try self.members.map { try $0.toUI() },
            restaurants: try self.restaurants.compactMap { try $0.toUI() },
        )
    }
}
