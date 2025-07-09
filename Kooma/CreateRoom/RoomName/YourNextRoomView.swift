
import SwiftUI

struct YourNextRoomView: View {
	@State private var roomCode = ""
	@State private var presentSheet = false

	// MARK: ViewModels
	@State private var roomCreationVM: RoomCreationViewModel
    var userManager: UserManager

    init(user: UserUI, userManager: UserManager) {
        self.userManager = userManager
        _roomCreationVM = State(wrappedValue: RoomCreationViewModel(user: self.userManager.currentUser ?? UserUI(id: UUID().uuidString, name: "ErrorName")))
	}

    var body: some View {
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

				NavigationLink(destination: ResearchRoomView(), label: {
					NavigationButton(text: "Join Room")
						.frame(maxWidth: .infinity, alignment: .trailing)
				})
				Spacer()
			}
			.padding(.horizontal, 16)
			.navigationTitle("Your Next Room")
			.navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $presentSheet, content: {
                if let room = self.roomCreationVM.room {
                    SearchAddressView(room: room, presentSheet: $presentSheet)
                }
            })
            .onAppear(perform: {
                print("user's id: \(self.roomCreationVM.user.id)")
                print("user's name: \(self.roomCreationVM.user.name)")
            })
			.navigationBarBackButtonHidden()
    }
}

#Preview {
    NavigationStack {
        YourNextRoomView(user: UserUI(id: UUID().uuidString, name: ""), userManager: UserManager())
    }
}

