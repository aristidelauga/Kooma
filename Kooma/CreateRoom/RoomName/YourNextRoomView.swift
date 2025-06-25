
import SwiftUI

struct YourNextRoomView: View {
	@State private var path = NavigationPath()
	@State private var roomCode = ""
	@State private var presentSheet = false
	@State private var showRoomsList = false

	// MARK: ViewModels
	@State private var roomCreationVM: RoomCreationViewModel

	init(user: UserUI) {
		_roomCreationVM = State(wrappedValue: RoomCreationViewModel(user: user))
	}

    var body: some View {
		NavigationStack(path: $path) {
			VStack(alignment: .leading, spacing: 0) {

				// MARK: - Create a Room
				TextHeading600(text: "Create a Room")
					.padding(.top, 25)
				KMTextfield(text: $roomCreationVM.name, placeholder: "Name your room")
					.padding(.vertical, 16)

				VStack {
					MainButton(text: "Create Room", maxWidth: 140) {
						presentSheet = true
						self.roomCreationVM.createRoomWithName(with: self.roomCreationVM.user)
					}
					.frame(maxWidth: .infinity, alignment: .trailing)
					.disabled(roomCreationVM.name.isEmpty)
				}

				// MARK: - Join a Room
				TextHeading600(text: "Join a Room")
					.padding(.top, 92)

				KMTextfield(text: $roomCode, placeholder: "Enter Room Code")
					.padding(.vertical, 16)

					Button {
						path.append("ResearchRoomView")
					} label: {
						NavigationButton(text: "Join Room")
					}
				.frame(maxWidth: .infinity, alignment: .trailing)
				Spacer()
			}
			.padding(.horizontal, 16)
			.navigationTitle("Your Next Room")
			.navigationBarTitleDisplayMode(.inline)
//			.fullScreenCover(isPresented: $presentSheet, content: {
//				if let room = self.roomCreationVM.room {
//					SearchAddressView(room: room, presentSheet: $showRoomsList)
//				}
//			})
			.fullScreenCover(isPresented: $presentSheet, onDismiss: {
				self.showRoomsList = true
			}, content: {
				if let room = self.roomCreationVM.room {
					SearchAddressView(room: room, presentSheet: $presentSheet)
				}
			})
			.navigationDestination(for: String.self) { name in
				ResearchRoomView(navigationPath: $path)
			}
			.navigationDestination(isPresented: $showRoomsList, destination: {
				RoomsListView()
			})
			.onAppear {
				print("Current user: \(self.roomCreationVM.user.name)")
			}
			.navigationBarBackButtonHidden()
		}
    }
}

#Preview {
    NavigationStack {
		YourNextRoomView(user: UserUI(id: UUID(), name: ""))
    }
}
