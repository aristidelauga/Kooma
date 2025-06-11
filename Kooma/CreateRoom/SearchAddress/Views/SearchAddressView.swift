
import SwiftUI

struct SearchAddressView: View {
	@State private var viewModel = SearchAddressViewModel()
	@FocusState private var isFocusedTexField: Bool
    var body: some View {
		VStack(alignment: .leading) {
			TextHeading600(text: "Where are you starting from?")
			TextField("Type an address", text: $viewModel.searchableText)
				.foregroundStyle(.kmKaki)
				.padding(.leading, 8)
				.padding(.vertical, 12)
				.background(Color.kmBeigeSecondary)
				.textInputAutocapitalization(.words)
				.cornerRadius(12)
				.autocorrectionDisabled()
				.focused($isFocusedTexField)
				.onChange(of: viewModel.searchableText, { oldValue, newValue in
					viewModel.searchAddress(newValue)
				})
				.onAppear {
					isFocusedTexField = true
				}

			List(self.viewModel.results) { address in
				VStack(alignment: .leading) {
					Text(address.title)
					Text(address.subtitle)
						.font(.caption)
				}
//				.background(Color.kmBeigeSecondary)
			}
			.listStyle(.plain)
			.listRowBackground(Color.kmBeigeSecondary)

			.background(.kmBeigeSecondary)
			.edgesIgnoringSafeArea(.bottom)
		}
    }
}

#Preview {
    SearchAddressView()
}
