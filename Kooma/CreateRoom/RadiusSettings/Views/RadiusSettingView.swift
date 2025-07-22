
import SwiftUI
import MapKit

struct RadiusSettingView: View {
	@State private var radiusSettingViewModel: RadiusSettingViewModel
    @State private var slider: Double = 0.0
    var navigationVM: NavigationViewModel

    init(room: RoomUI, service: FirestoreService, navigationVM: NavigationViewModel) {
        _radiusSettingViewModel = State(wrappedValue: RadiusSettingViewModel(service: service, room: room))
        self.navigationVM = navigationVM
	}

    var body: some View {
		ZStack {
			VStack(alignment: .leading) {
				TextHeading600(text: "Location")
					.padding(.top, 12)
				if let address = self.radiusSettingViewModel.room.address {
					AddressInfoView(address: address)
						.padding(.top, 12)
						.padding(.bottom, 32)
				}
				TextHeading600(text: "Radius")
					.padding(.bottom, 12)
				RadiusSliderView(slider: $slider)
				Spacer()

				MainButton(text: "Submit") {
					Task {
                        try await radiusSettingViewModel.searchRestaurants(within: slider)
                        try await self.radiusSettingViewModel.addNewRoom(self.radiusSettingViewModel.room)
                        print("path when tapping on `submit` in RadiusSettingView: \(self.navigationVM.path.count)")
                        self.navigationVM.showRoomsListView()
                        print("path when tapping on `submit` in RadiusSettingView: \(self.navigationVM.path.count), after calling `showRoomsListView`.")
                        
					}
				}
				.frame(maxWidth: .infinity, alignment: .center)
			}
			.padding(.horizontal, 16)
			.navigationTitle("Lunch spots research")
			.navigationBarTitleDisplayMode(.inline)
			.background(
				Color.kmBeige
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.edgesIgnoringSafeArea(.all)
			)
			.navigationBarBackButtonHidden()
			if radiusSettingViewModel.isLoading {
				LoadingView()
					.edgesIgnoringSafeArea(.all)
			}
		}
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
    NavigationView {
        RadiusSettingView(room: RoomUI(id: "12b489", name: "Expédition 33", administrator: UserUI(id: UUID().uuidString, name: "Gustave")), service: FirestoreService(), navigationVM: NavigationViewModel())
    }
}
