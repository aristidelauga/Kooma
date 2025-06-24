
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
	static let emptyElement = RestaurantDTO(id: "", name: "", phoneNumber: "", placemark: CodablePlacemark(from: MKPlacemark(coordinate: CLLocationCoordinate2D())), url: "")

	// TODO: Check if Apple Maps' displays the "\" when I open the address in Apple Maps
	private func createAddress() -> String {
		if let subThoroughfare = self.placemark.subThoroughfare, let thoroughfare = self.placemark.thoroughfare {
			let addressParts = [
				self.placemark.name/*?.replacingOccurrences(of: "\\", with: "")*/,
				"\(subThoroughfare) \(thoroughfare/*.replacingOccurrences(of: "\\", with: "")*/)",
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
			url: self.url
		)
	}

}

//extension MKPlacemark: Codable { }
