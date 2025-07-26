
import Foundation
import MapKit

class MockLocalSearchCompleter: MKLocalSearchCompleter {
    var setQueryFragment: String?
    override var queryFragment: String {
        get { setQueryFragment ?? "" }
        set { setQueryFragment = newValue }
    }
}
