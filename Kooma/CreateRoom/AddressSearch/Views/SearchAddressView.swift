
import SwiftUI

struct SearchAddressView: View {
	@State private var searchAddressViewModel: SearchAddressViewModel
	@State private var path = NavigationPath()
	@State private var shouldNavigate = false
	@FocusState private var isFocusedTexField: Bool

	init(room: RoomUI) {
		_searchAddressViewModel = State(wrappedValue: SearchAddressViewModel(room: room))
	}

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
					MainButton(text: "Continue") {
						Task {
							try await self.searchAddressViewModel.assignAddressToRoom()
							self.shouldNavigate = true
						}
					}
					.frame(maxWidth: .infinity, alignment: .center)

					if let room = self.searchAddressViewModel.room {
						NavigationLink(
							destination: RadiusSettingView(room: room),
							isActive: $shouldNavigate
						) {
							EmptyView()
						}
					}
				}
			}
			.background(Color.kmBeige.edgesIgnoringSafeArea(.bottom))
		}
    }
}

#Preview {
	SearchAddressView(room: RoomUI(id: UUID(), name: "Kowabunga"))
}
