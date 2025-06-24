
import Foundation
import MapKit

@MainActor
@Observable final class MapViewModel {
	var region = MKCoordinateRegion()
	private(set) var annotationItems: [AnnotationItem] = []
	
	func getPlace(from address: AddressResult) {
		let request = MKLocalSearch.Request()
		let title = address.title
		let subtitle = address.subtitle
		
		request.naturalLanguageQuery = subtitle.contains(title) ? subtitle : title + ", " + subtitle
		
		let search = MKLocalSearch(request: request)
		search.start { [weak self] response, error in
			guard let self, let response else { return }
			let items = response.mapItems.compactMap {
				AnnotationItem(
					latitude: $0.placemark.coordinate.latitude,
					longitude: $0.placemark.coordinate.longitude
				)
			}
			self.annotationItems = items
			self.region = response.boundingRegion
		}
	}
}
