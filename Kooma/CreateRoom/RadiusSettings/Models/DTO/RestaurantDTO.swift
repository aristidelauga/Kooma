
import Foundation
import MapKit

struct RestaurantDTO: Sendable, Identifiable, Codable {
	let id: String
	let name: String
	let phoneNumber: String
	let placemark: CodablePlacemark
	let url: String
}

extension RestaurantDTO: UIModelConvertible {
	private func createAddress() -> String {
		if let subThoroughfare = self.placemark.subThoroughfare, let thoroughfare = self.placemark.thoroughfare {
			let addressParts = [
				self.placemark.name,
				"\(subThoroughfare) \(thoroughfare)",
				self.placemark.postalCode,
				self.placemark.locality,
				self.placemark.country
			].compactMap { $0 }

			return addressParts.joined(separator: ", ")
		}
		return ""
	}

	func toUI() throws -> RestaurantUI {
		RestaurantUI(
			id: self.id,
			name: self.name,
			phoneNumber: self.phoneNumber,
			address: self.createAddress(),
			url: self.url,
		)
	}
}
