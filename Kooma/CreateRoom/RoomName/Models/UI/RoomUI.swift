
import Foundation

struct RoomUI: Identifiable, Codable, Sendable {
	var id: String?
    var hostID: String {
        administrator.id
    }
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
			"RoomIcon-1",
			"RoomIcon-2",
			"RoomIcon-3"
		].randomElement()!

	}
    
    init(
        id: String,
        name: String?,
        administrator: UserUI,
        address: String?,
        members: [UserUI],
        restaurants: [RestaurantUI]
    ) {
        self.id = id
        self.name = name
        self.administrator = administrator
        self.address = address
        self.members = members
        self.restaurants = restaurants
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
       do {
           if let restaurants = self.restaurants {
                restaurantsDTO = try await withThrowingTaskGroup(of: RestaurantDTO.self) { group in
                    for restaurant in restaurants {
                        group.addTask {
                            do {
                                let dto = try await restaurant.toDTO()
                                print("Successfully converted restaurant \(restaurant.name ?? "Unnamed")")
                                return dto
                            } catch {
                                print("Failed to convert restaurant \(restaurant.name ?? "Unnamed"): \(error.localizedDescription)")
                                throw error
                            }
                        }
                    }
                    var results: [RestaurantDTO] = []
                    for try await DTO in group {
                        print("Converted RestaurantDTO: \(DTO.name)")
                        results.append(DTO)
                    }
                    print("Final results count inside task group: \(results.count)")
                    return results
                }
            }
        } catch {
            restaurantsDTO = []
            throw NSError(domain: "RoomUI", code: 112, userInfo: [NSLocalizedDescriptionKey: "restaurants is nil"])
        }
        print("restaurants' count: \(restaurantsDTO.count)")
        return restaurantsDTO
    }
    
    func toDTO() async throws -> RoomDTO {
        guard let address = self.address else {
            throw NSError(domain: "RoomUI", code: 1, userInfo: [NSLocalizedDescriptionKey: "Address is nil"])
        }
        let administratorDTO = try self.administrator.toDTO()
                
        guard let members = self.members else {
            throw NSError(domain: "RoomUI", code: 7, userInfo: [NSLocalizedDescriptionKey: "Members is nil"])
        }
        let membersDTO = try members.compactMap { try $0.toDTO() }
        
        for member in membersDTO {
            print("toDTO membersDTO: \(member)")
        }
        
        guard let restaurants = self.restaurants else {
            throw NSError(domain: "RoomUI", code: 8, userInfo: [NSLocalizedDescriptionKey: "restaurants is nil"])
        }
        let restaurantsDTO = try await self.gatherRestaurantsDTO()
        for restaurant in restaurants {
            print("Restaurant's name: \(restaurant.name)")
        }
        
        let RoomDTO = RoomDTO(
            id: nil,
            name: self.name ?? "",
            administrator: administratorDTO,
            address: address,
            members: membersDTO,
            restaurants: restaurantsDTO
        )
        return RoomDTO
    }
}
