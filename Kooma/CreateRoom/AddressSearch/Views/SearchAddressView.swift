
import SwiftUI

struct SearchAddressView: View {
	@State private var searchAddressViewModel: SearchAddressViewModel
	@State private var shouldNavigate = false
	@FocusState private var isFocusedTexField: Bool
    var navigationVM: NavigationViewModel
    var service: FirestoreService

    init(room: RoomUI, service: FirestoreService, navigationVM: NavigationViewModel) {
        _searchAddressViewModel = State(wrappedValue: SearchAddressViewModel(room: room))
        self.service = service
        self.navigationVM = navigationVM
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
                        self.searchAddressViewModel.assignAddressToRoom()
                        self.shouldNavigate = true
                        if let room = searchAddressViewModel.room {
                            self.navigationVM.goToRadiusSettingView(withRoom: room)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .background(Color.kmBeige.edgesIgnoringSafeArea([.bottom, .top]))
		}
        .navigationBarBackButtonHidden()
        .navigationTitle("Address Search")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button {
                    self.navigationVM.goToYourNextRoomView()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .foregroundStyle(.kmYellow)
                        .frame(width: 14, height: 14)
                        .padding(.trailing, 12)
                }
            }
        }
    }
}

#Preview {
    SearchAddressView(
        room: RoomUI(
            id: "12b489",
            name: "Expédition 33",
            administrator: UserUI(id: UUID().uuidString, name: "Gustave")
        ),
        service: FirestoreService(),
        navigationVM: NavigationViewModel()
    )
}
