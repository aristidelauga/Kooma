
import Foundation

struct RestaurantDomain: Identifiable, Sendable, Codable {
    let id: String
    let name: String
    let phoneNumber: String
    let address: String
    let url: String
    //TODO: Check if it wouldn't be better to create rather an array of String containing the ID's of the voters
    let vote: Int
}

extension RestaurantDomain {
    func toUI() -> RestaurantUI {
        RestaurantUI(
            id: self.id,
            name: self.name,
            phoneNumber: self.phoneNumber,
            address: self.address,
            url: self.url,
            vote: self.vote
        )
    }
}
