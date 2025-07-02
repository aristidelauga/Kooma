
import SwiftUI

struct RoomsListView: View {
	@Environment(RoomsListViewModel.self) private var roomsListVM
	@Environment(NavigationViewModel.self) private var navigationVM
	@Environment(UserManager.self) private var userManager
	@State private var showYourNextRoom = false
	var body: some View {
			VStack {
				TextHeading600(text: "Your Rooms")
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(.leading, 12)
				ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
						ForEach(self.roomsListVM.rooms) { room in
                            NavigationLink(destination: RoomDetailsView(room: room), label: {
                                RoomCell(room: room)
                            })
                        }
                    }
                    .padding(.bottom, 12)
				}
				.padding(12)

				TextHeading600(text: "Rooms you are invited")
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(.leading, 12)

				Spacer()

				MainButton(text: "New Room", maxWidth: 142) {
                    self.navigationVM.goToYourNextRoomView()
                    print("navigationVM.currentView: \(self.navigationVM.path)")
				}
				.frame(maxWidth: .infinity, alignment: .trailing)
				.padding(.trailing, 38)
			}
		.onAppear {
			print("Rooms' count in RoomListView: \(roomsListVM.rooms.count)")
		}
		.background(
			Color.kmBeige
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.edgesIgnoringSafeArea(.all)
		)
		.navigationTitle("Your Rooms")
		.navigationBarTitleDisplayMode(.inline)
		.navigationBarBackButtonHidden()
	}
}

#Preview {
	RoomsListView()
		.environment(RoomsListViewModel())
		.environment(UserManager())
        .environment(NavigationViewModel())
}
