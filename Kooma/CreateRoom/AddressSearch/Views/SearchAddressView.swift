
import SwiftUI

struct SearchAddressView: View {
	@State private var searchAddressViewModel = SearchAddressViewModel()
	@FocusState private var isFocusedTexField: Bool
    var body: some View {
		NavigationView {
			VStack(alignment: .leading) {

				TextHeading600(text: "Where are you starting from?")
					.padding(.leading, 16)
					.padding(.vertical, 20)

				TextField("Type an address", text: $searchAddressViewModel.searchableText)
					.foregroundStyle(.kmKaki)
					.padding(.leading, 8)
					.padding(.vertical, 12)
					.background(Color.kmBeigeSecondary)
					.cornerRadius(12)
					.padding(.horizontal, 16)
					.textInputAutocapitalization(.words)
					.autocorrectionDisabled()
					.focused($isFocusedTexField)
					.onSubmit({
						isFocusedTexField = false
					})
					.onChange(of: searchAddressViewModel.searchableText, { oldValue, newValue in
						searchAddressViewModel.searchAddress(newValue)
					})
					.onAppear {
						isFocusedTexField = true
					}

				if isFocusedTexField {
					AddressListView(searchAddressViewModel: searchAddressViewModel)
				} else {
					Spacer()
					NavigationLink(destination: RadiusSettingView(address: searchAddressViewModel.searchableText)) {
						NavigationButton(text: "Continue")
					}
					.frame(maxWidth: .infinity, alignment: .center)
				}
			}
		}
		.background(Color.kmBeige.edgesIgnoringSafeArea(.bottom))
    }
}

#Preview {
    SearchAddressView()
}
