
import SwiftUI

struct RoomsListView: View {
	@Environment(RoomsListViewModel.self) private var roomsListVM
    var body: some View {
		ZStack(alignment: .bottom) {
			ScrollView(.vertical, showsIndicators: false) {
				ForEach(self.roomsListVM.rooms) { room in
					RoomCell(room: room)
						.padding(.leading, 12)
						.onTapGesture {
							print("Room' id: \(room.id)")
						}
				}
				Spacer()
			}
			MainButton(text: "New Room", maxWidth: 142) {
				//
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
}
