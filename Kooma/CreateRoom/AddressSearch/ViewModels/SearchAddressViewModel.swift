
import Foundation
import MapKit

@MainActor
@Observable final class SearchAddressViewModel: NSObject {
	private(set) var results: Array<AddressResult> = []
	var searchableText = ""
	var room: RoomUI?

	private var localSearchCompleter: MKLocalSearchCompleter

	override init() {
		self.localSearchCompleter = MKLocalSearchCompleter()
		super.init()
		self.localSearchCompleter.delegate = self
	}

	init(room: RoomUI) {
		self.room = room
		self.localSearchCompleter = MKLocalSearchCompleter()
		super.init()
		self.localSearchCompleter.delegate = self
	}

	func searchAddress(_ searchableText: String) {
		guard !searchableText.isEmpty else { return }
		localSearchCompleter.queryFragment = searchableText
	}

	func fillSearchText(result: String) {
		searchableText = result
	}

	func assignAddressToRoom() {
				self.room?.address = self.searchableText
				print("self.searchableText in SearchAddressViewModel: \(self.searchableText)")
				print("self.room?.address in SearchAddressViewModel: \(self.room?.address)")
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
