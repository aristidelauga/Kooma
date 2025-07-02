

import Foundation
import CoreLocation
import MapKit

struct RestaurantUI: Identifiable, Sendable, Codable {
	let id: String
	let name: String
	let phoneNumber: String
	let address: String
	let url: String
    var vote: Int
}

extension RestaurantUI {
    func toDTO() async throws -> RestaurantDTO {
        let geocoder = CLGeocoder()
        
        guard let placemark = try await geocoder.geocodeAddressString(self.address).first, let mkPlacemark = placemark as? MKPlacemark else {
            throw URLError(.badServerResponse)
        }
        
        let codablePlacemark = CodablePlacemark(from: mkPlacemark)
        
        return RestaurantDTO(
            id: self.id,
            name: self.name,
            phoneNumber: self.phoneNumber,
            placemark: codablePlacemark,
            url: self.url,
            vote: self.vote
        )
    }
}
