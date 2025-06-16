
import Foundation
import MapKit

@MainActor
@Observable final class SearchAddressViewModel: NSObject {
	private(set) var results: Array<AddressResult> = []
	var searchableText = ""

	private var localSearchCompleter: MKLocalSearchCompleter

	override init() {
		self.localSearchCompleter = MKLocalSearchCompleter()
		super.init()
		self.localSearchCompleter.delegate = self
	}

//	private var localSearchCompleter: MKLocalSearchCompleter = {
//		let completer = MKLocalSearchCompleter()
//		completer.delegate = self
//		return completer
//	}()

	func searchAddress(_ searchableText: String) {
		guard !searchableText.isEmpty else { return }
		localSearchCompleter.queryFragment = searchableText
	}

	func fillSearchText(result: String) {
		searchableText = result
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
