

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
        print("Attempting to convert RestaurantUI to DTO: \(self.name ?? "Unknown")")
        do {
            let geocoder = CLGeocoder()
            
            guard let placemark = try await geocoder.geocodeAddressString(self.address).first, let mkPlacemark = placemark as? MKPlacemark else {
                print("ERROR: Required property missing for \(self.name ?? "Unknown")")
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
        } catch {
            throw NSError(domain: "RestaurantUI", code: 14, userInfo: [NSLocalizedDescriptionKey: "Instance of RestaurantUI is nil"])
        }
    }
}
