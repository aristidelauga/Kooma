
import SwiftUI
import MapKit

struct RadiusSettingView: View {
	@State private var radiusSettingViewModel: RadiusSettingViewModel
	@Environment(RoomsListViewModel.self) private var roomsListVM
	@State private var slider: Double = 0.0
	@Binding var presentSheet: Bool

	init(room: RoomUI, presentSheet: Binding<Bool>) {
		_radiusSettingViewModel = State(wrappedValue: RadiusSettingViewModel(room: room))
		_presentSheet = presentSheet
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
						self.presentSheet = false
						await radiusSettingViewModel.searchRestaurants(within: slider)
						self.roomsListVM.addNewRoom(self.radiusSettingViewModel.room)
						print("roomsListVM.rooms.count: \(self.roomsListVM.rooms.count)")
//						self.dismiss()
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
    }
}

#Preview {
    NavigationView {
		RadiusSettingView(room: RoomUI(id: "12b489", name: "Eeastquadron", administrator: UserUI(id: UUID(), name: "Lead")), presentSheet: .constant(true))
    }
}
