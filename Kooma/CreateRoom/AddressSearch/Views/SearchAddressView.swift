
import SwiftUI

struct SearchAddressView: View {
	@State private var searchAddressViewModel: SearchAddressViewModel
	@State private var shouldNavigate = false
	@FocusState private var isFocusedTexField: Bool
	@Binding var presentSheet: Bool
    var service: FirestoreService

    init(room: RoomUI, presentSheet: Binding<Bool>, service: FirestoreService) {
		_searchAddressViewModel = State(wrappedValue: SearchAddressViewModel(room: room))
		_presentSheet = presentSheet
        self.service = service
	}

    var body: some View {
		NavigationView {
            VStack(alignment: .leading) {
                
                if let room = self.searchAddressViewModel.room {
                    NavigationLink(destination: RadiusSettingView(room: room, service: self.service, presentSheet: $presentSheet), isActive: $shouldNavigate) {
                        EmptyView()
                    }
                }
                
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
                        self.searchAddressViewModel.assignAddressToRoom()
                        self.shouldNavigate = true
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
			.background(Color.kmBeige.edgesIgnoringSafeArea(.bottom))
		}
    }
}

#Preview {
    SearchAddressView(room: RoomUI(id: "12b489", name: "Expédition 33", administrator: UserUI(id: UUID().uuidString, name: "Gustave")), presentSheet: .constant(true), service: FirestoreService())
}
