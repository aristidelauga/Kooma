
import Foundation

struct RestaurantDomain: Identifiable, Sendable, Codable {
    let id: String
    let name: String
    let phoneNumber: String
    let address: String
    let placemark: CodablePlacemark
    let url: String
}

extension RestaurantDomain {
    func toUI() -> RestaurantUI {
        RestaurantUI(
            id: self.id,
            name: self.name,
            phoneNumber: self.phoneNumber,
            address: self.address,
            placemark: self.placemark,
            url: self.url
        )
    }
}
