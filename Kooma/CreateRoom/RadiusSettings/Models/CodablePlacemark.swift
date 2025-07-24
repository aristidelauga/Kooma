
import Foundation
import MapKit

struct CodablePlacemark: Codable, Sendable {
	let latitude: Double
	let longitude: Double
	let name: String?
	let country: String?
	let postalCode: String?
	let locality: String?
	let thoroughfare: String?
	let subThoroughfare: String?

	init(from placemark: MKPlacemark) {
		self.latitude = placemark.coordinate.latitude
		self.longitude = placemark.coordinate.longitude
		self.name = placemark.name
		self.country = placemark.country
		self.postalCode = placemark.postalCode
		self.locality = placemark.locality
		self.thoroughfare = placemark.thoroughfare
		self.subThoroughfare = placemark.subThoroughfare
	}
    
    init(
        latitude: CLLocationDegrees,
        longitude: CLLocationDegrees,
        name: String,
        country: String,
        postalCode: String,
        locality: String,
        thoroughfare: String,
        subThoroughfare: String
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.country = country
        self.postalCode = postalCode
        self.locality = locality
        self.thoroughfare = thoroughfare
        self.subThoroughfare = subThoroughfare
    }

	func toMKPlacemark() -> MKPlacemark {
		let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
		let addressDict: [String: Any] = [
			"Name": name as Any,
			"Country": country as Any,
			"ZIP": postalCode as Any,
			"City": locality as Any,
			"Street": thoroughfare as Any,
			"SubThoroughfare": subThoroughfare as Any
		]
		return MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
	}
}
