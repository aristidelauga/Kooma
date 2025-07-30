
import Foundation
import MapKit

@MainActor
@Observable final class SearchAddressViewModel: NSObject {
	private(set) var results: Array<AddressResult> = []
	var searchableText = ""
	var room: RoomUI?

	var localSearchCompleter: MKLocalSearchCompleter

	override init() {
		self.localSearchCompleter = MKLocalSearchCompleter()
		super.init()
		self.localSearchCompleter.delegate = self
	}

	init(room: RoomUI, localSearchCompleter: MKLocalSearchCompleter = MKLocalSearchCompleter()) {
		self.room = room
		self.localSearchCompleter = localSearchCompleter
		super.init()
		self.localSearchCompleter.delegate = self
	}

	convenience init(localSearchCompleter: MKLocalSearchCompleter) {
		self.init(room: RoomUI(id: nil, name: nil, administrator: UserUI(id: "", name: "")), localSearchCompleter: localSearchCompleter)
		self.room = nil
	}

    /// Uses the LocalSearchCompleter to search for the address corresponding
    /// to the one written in the textfield
	func searchAddress(_ searchableText: String) {
		guard !searchableText.isEmpty else { return }
		localSearchCompleter.queryFragment = searchableText
	}

    /// Fills the address matching the address written in the texfield
    /// Triggered when a user taps on any cell of the displayed results
    /// of the List
	func fillSearchText(result: String) {
		searchableText = result
	}

    /// Assigns the address written in the textfiel to the room
	func assignAddressToRoom() {
        self.room?.address = self.searchableText
	}
}


extension SearchAddressViewModel: MKLocalSearchCompleterDelegate {
	nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
		let resultsCopy = completer.results.map { AddressResult(title: $0.title, subtitle: $0.subtitle) }
		Task { @MainActor in
			results = resultsCopy
		}
	}

	nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
		print(error)
	}
}
