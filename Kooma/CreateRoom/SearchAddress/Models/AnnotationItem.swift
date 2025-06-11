
import Foundation
import MapKit

struct AnnotationItem: Identifiable {
	let id = UUID()
	let latitude: Double
	let longitude: Double
	var coordinate: CLLocationCoordinate2D {
		CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
	}
}
