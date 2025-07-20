

import Foundation
import CoreLocation
import MapKit

/// Hashable protocol implemented so RoomUI is Hashable
struct RestaurantUI: Identifiable, Equatable, Hashable  {
    
    static func == (lhs: RestaurantUI, rhs: RestaurantUI) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
	let id: String
	let name: String
	let phoneNumber: String
	let address: String
	let url: String
    
    init(id: String, name: String, phoneNumber: String, address: String, url: String) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.address = address
        self.url = url
    }
    
    
}

extension RestaurantUI: DomainModelConvertible {
    func toDomain() throws -> RestaurantDomain {
        RestaurantDomain(
            id: self.id,
            name: self.name,
            phoneNumber: self.phoneNumber,
            address: self.address,
            url: self.url,
        )
    }
}
