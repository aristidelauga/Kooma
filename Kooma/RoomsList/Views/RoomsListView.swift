
import SwiftUI

struct RoomsListView: View {
	@Environment(RoomsListViewModel.self) private var roomsListVM
	@Environment(UserManager.self) private var userManager
	@State private var showYourNextRoom = false
    var body: some View {
            HStack {
                TextHeading600(text: "Your Rooms")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 12)
                ScrollView(.horizontal, showsIndicators: false) {
                    ForEach(self.roomsListVM.rooms) { room in
                        RoomCell(room: room)
                            .padding(.horizontal, 12)
                            .onTapGesture {
                                print("Room' id: \(room.id)")
                            }
                    }
                }
                TextHeading600(text: "Rooms you are invited")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 12)
                
                Spacer()

                MainButton(text: "New Room", maxWidth: 142) {
                    self.showYourNextRoom = true
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
		.navigationDestination(isPresented: $showYourNextRoom) {
			if let user = userManager.currentUser {
				YourNextRoomView(user: user)
			}
		}
    }
}

#Preview {
    RoomsListView()
        .environment(RoomsListViewModel())
        .environment(UserManager())
}
