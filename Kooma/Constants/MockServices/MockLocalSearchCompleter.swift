
import Foundation
import MapKit

/// Used for testing purposes to mimick the behaviour of `SearchAddressViewModel`'s extension
class MockLocalSearchCompleter: MKLocalSearchCompleter {
    var setQueryFragment: String?
    override var queryFragment: String {
        get { setQueryFragment ?? "" }
        set { setQueryFragment = newValue }
    }
}
