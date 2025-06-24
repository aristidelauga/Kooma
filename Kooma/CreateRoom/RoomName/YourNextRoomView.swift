
import SwiftUI

struct YourNextRoomView: View {
	@State private var roomCode = ""
	@State private var createRoomSheet = false
	@State private var path = NavigationPath()

	// MARK: ViewModels
	@State private var roomCreationVM = RoomCreationViewModel()


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
						createRoomSheet = true
						Task {
							try await self.roomCreationVM.createRoomWithName()
						}
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
			.fullScreenCover(isPresented: $createRoomSheet, content: {
				if let room = self.roomCreationVM.room {
					SearchAddressView(room: room)
				}
			})
			.navigationDestination(for: String.self) { name in
				ResearchRoomView(navigationPath: $path)
			}
			.navigationBarBackButtonHidden()
		}
    }
}

#Preview {
    NavigationStack {
		YourNextRoomView()
    }
}
