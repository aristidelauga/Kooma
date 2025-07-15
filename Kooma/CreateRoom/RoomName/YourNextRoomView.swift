
import SwiftUI

struct YourNextRoomView: View {
	@State private var roomCode = ""
	@State private var presentSheet = false

	// MARK: ViewModels
	@State private var yourNextRoomVM: YourNextRoomViewModel
    var userManager: UserManager
    @Environment(NavigationViewModel.self) private var navigationVM
    @Environment(FirestoreService.self) private var service

    init(userManager: UserManager) {
        self.userManager = userManager
        _yourNextRoomVM = State(wrappedValue: YourNextRoomViewModel(user: self.userManager.currentUser ?? UserUI(id: UUID().uuidString, name: "ErrorName")))
	}

    var body: some View {
			VStack(alignment: .leading, spacing: 0) {

				// MARK: - Create a Room
				TextHeading600(text: "Create a Room")
					.padding(.top, 25)
				KMTextfield(text: $yourNextRoomVM.name, placeholder: "Name your room")
					.padding(.vertical, 16)

				VStack {
					MainButton(text: "Create Room", maxWidth: 140) {
						presentSheet = true
						self.yourNextRoomVM.createRoomWithName(with: self.yourNextRoomVM.user)
					}
					.frame(maxWidth: .infinity, alignment: .trailing)
					.disabled(yourNextRoomVM.name.isEmpty)
				}

				// MARK: - Join a Room
				TextHeading600(text: "Join a Room")
					.padding(.top, 92)

				KMTextfield(text: $roomCode, placeholder: "Enter Room Code")
					.padding(.vertical, 16)

                NavigationLink(destination: ResearchRoomView(
                    service: self.service,
                    code: roomCode,
                    userManager: self.userManager,
                    navigationVM: navigationVM), label: {
					NavigationButton(text: "Join Room")
						.frame(maxWidth: .infinity, alignment: .trailing)
				})
                .disabled(self.roomCode.isEmpty)
				Spacer()
			}
			.padding(.horizontal, 16)
			.navigationTitle("Your Next Room")
			.navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(
                isPresented: $presentSheet,
                content: {
                    if let room = self.yourNextRoomVM.room {
                        SearchAddressView(
                            room: room,
                            presentSheet: $presentSheet,
                            service: self.service
                        )
                    }
                })
			.navigationBarBackButtonHidden()
    }
}

#Preview {
    NavigationStack {
        YourNextRoomView(userManager: UserManager())
    }
}

