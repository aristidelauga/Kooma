
import Foundation

struct RoomUI: Identifiable, Codable, Sendable {
	var id: String
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

extension RoomUI {
    private func gatherRestaurantsDTO() async throws -> [RestaurantDTO] {
        var restaurantsDTO = [RestaurantDTO]()
        if let restaurants = self.restaurants {
            restaurantsDTO = try await withThrowingTaskGroup(of: RestaurantDTO.self) { group in
                for restaurant in restaurants {
                    group.addTask {
                        try await restaurant.toDTO()
                    }
                }
                
                var results: [RestaurantDTO] = []
                for try await DTO in group {
                    results.append(DTO)
                }
                return results
            }
        } else {
            restaurantsDTO = []
        }
        return restaurantsDTO
    }
    
    func toDTO() async throws -> RoomDTO {
        guard let address = self.address else { throw NSError(domain: "RoomUI", code: 1, userInfo: [NSLocalizedDescriptionKey: "Address is nil"]) }
        
        let administratorDTO = try self.administrator.toDTO()
        
        let membersDTO = try self.members.map { try $0.toDTO() }
        
        let restaurantsDTO = try await gatherRestaurantsDTO()
        
        return RoomDTO(
            name: self.id,
            administrator: administratorDTO,
            address: address,
            members: membersDTO,
            restaurants: restaurantsDTO
        )
    }
}
