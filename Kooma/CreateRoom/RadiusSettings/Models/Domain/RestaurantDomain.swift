
import Foundation

struct RestaurantDomain: Identifiable, Sendable, Codable {
    let id: String
    let name: String
    let phoneNumber: String
    let address: String
    let latitude: Double
    let longitude: Double
    let url: String
}

extension RestaurantDomain {
    func toUI() -> RestaurantUI {
        RestaurantUI(
            id: self.id,
            name: self.name,
            phoneNumber: self.phoneNumber,
            address: self.address,
            latitude: self.latitude,
            longitude: self.longitude,
            url: self.url
        )
    }
}
