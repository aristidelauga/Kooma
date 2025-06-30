

import Foundation

struct RestaurantUI: Identifiable, Sendable, Codable {
	let id: String
	let name: String
	let phoneNumber: String
	let address: String
	let url: String
}

//extension RestaurantUI: DTOModelConvertible {
//    func toDTO() throws -> RestaurantDTO {
//        RestaurantDTO(
//            id: self.id,
//            name: self.name,
//            phoneNumber: self.phoneNumber,
//            placemark: ,
//            url: self.url
//        )
//    }
//}
