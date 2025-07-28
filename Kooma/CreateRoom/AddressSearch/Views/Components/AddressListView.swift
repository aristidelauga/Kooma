
import SwiftUI

struct AddressListView: View {
	var searchAddressViewModel: SearchAddressViewModel
    var body: some View {
		List(self.searchAddressViewModel.results) { address in
			VStack(alignment: .leading) {
				Text(address.title)
				Text(address.subtitle)
					.font(.caption)
            }
            .foregroundStyle(.kmBlack)
			.background(Color.kmBeige)
			.listRowBackground(Color.kmBeige)
			.onTapGesture {
				self.searchAddressViewModel.fillSearchText(result: "\(address.title), \(address.subtitle)")
			}
		}
		.listStyle(.plain)
		.scrollIndicators(.hidden)
    }
}

#Preview {
	AddressListView(searchAddressViewModel: SearchAddressViewModel())
}
