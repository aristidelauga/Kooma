
import Foundation
import MapKit

class FixturesConstants {
    
    enum PlacemarkFixtures {
        
        private static let parisCoordinate = CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
        private static let parisAddress = [
            "Name": "Tour Eiffel",
            "Country": "France",
            "ZIP": "75007",
            "City": "Paris",
            "Street": "Champ de Mars",
            "SubThoroughfare": "5"
        ]
        
        private static let parisMkPlacemark = MKPlacemark(coordinate: parisCoordinate, addressDictionary: parisAddress)
        
        private static let lyonCoordinate = CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
        private static let lyonAddress = [
            "Name": "Tour Eiffel",
            "Country": "France",
            "ZIP": "75007",
            "City": "Paris",
            "Street": "Champ de Mars",
            "SubThoroughfare": "5"
        ]
        
        private static let lyonMkPlacemark = MKPlacemark(coordinate: parisCoordinate, addressDictionary: parisAddress)
        
        static let parisPlacemark = CodablePlacemark(from: parisMkPlacemark)
        static let lyonPlacemark = CodablePlacemark(from: parisMkPlacemark)

    }
}
