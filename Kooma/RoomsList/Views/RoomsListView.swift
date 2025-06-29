
import SwiftUI

struct RoomsListView: View {
	@Environment(RoomsListViewModel.self) private var roomsListVM
	@Environment(NavigationViewModel.self) private var navigationVM
	@Environment(UserManager.self) private var userManager
	@State private var showYourNextRoom = false
	var body: some View {
//		NavigationStack(path: $navigationVM.path) {
			VStack {
				TextHeading600(text: "Your Rooms")
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(.leading, 12)
				ScrollView(.horizontal, showsIndicators: false) {
					HStack {
						ForEach(self.roomsListVM.rooms) { room in
							RoomCell(room: room)
								.padding(.horizontal, 12)
								.onTapGesture {
									print("Room' id: \(room.id)")
								}
						}
					}
				}
				.padding(12)

				TextHeading600(text: "Rooms you are invited")
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(.leading, 12)

				Spacer()

				MainButton(text: "New Room", maxWidth: 142) {
					//						self.showYourNextRoom = true
//					if let user = userManager.currentUser {
					if let user = userManager.currentUser {
						print("👤 Going to YourNextRoomView with user: \(user.name)")
						self.navigationVM.goToYourNextRoomView()
					} else {
						print("No user")
					}
				}
				.frame(maxWidth: .infinity, alignment: .trailing)
				.padding(.trailing, 38)
			}
//		}
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
		.navigationDestination(for: AppRoute.self) { route in
			if route == AppRoute.yourNextRoom, let user = self.userManager.currentUser {
				YourNextRoomView(user: user)
			}
		}
		//		.navigationDestination(isPresented: $showYourNextRoom) {
		//			if let user = userManager.currentUser {
		//				YourNextRoomView(user: user)
		//			}
//		.navigationDestination(for: AppRoute.self) { route in
//			switch route {
//				case .yourNextRoom(user: self.userManager.currentUser):
//					if let user = self.userManager.currentUser {
//						YourNextRoomView(user: user)
//					}
//					default
//			}
//			if route == AppRoute.yourNextRoom, let user = self.userManager.currentUser {
//				YourNextRoomView(user: user)
//			}
//		}
	}
}

#Preview {
	RoomsListView()
		.environment(RoomsListViewModel())
		.environment(UserManager())
}
