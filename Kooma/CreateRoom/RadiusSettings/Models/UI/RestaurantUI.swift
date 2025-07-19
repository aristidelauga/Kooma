

import Foundation
import CoreLocation
import MapKit

struct RestaurantUI: Identifiable, Sendable, Codable, Equatable, Hashable {
	let id: String
	let name: String
	let phoneNumber: String
	let address: String
	let url: String
    var vote: Int
}

extension RestaurantUI: DomainModelConvertible {
    func toDomain() throws -> RestaurantDomain {
        RestaurantDomain(
            id: self.id,
            name: self.name,
            phoneNumber: self.phoneNumber,
            address: self.address,
            url: self.url,
            vote: self.vote
        )
    }
}
