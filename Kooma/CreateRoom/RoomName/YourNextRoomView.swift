
import SwiftUI

struct YourNextRoomView: View {
	@State private var roomName = ""
	@State private var roomCode = ""
	@State private var createRoomSheet = false
	@State private var path = NavigationPath()
    var body: some View {
		NavigationStack(path: $path) {
			VStack(alignment: .leading, spacing: 0) {

				// MARK: - Create a Room
				TextHeading600(text: "Create a Room")
					.padding(.top, 25)
				KMTextfield(text: $roomName, placeholder: "Name your room")
					.padding(.vertical, 16)

				VStack {
					MainButton(text: "Create Room", maxWidth: 140) {
						createRoomSheet = true
					}
					.frame(maxWidth: .infinity, alignment: .trailing)
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
				SearchAddressView()
			})
			.navigationDestination(for: String.self) { name in
				ResearchRoomView(navigationPath: $path)
					.onAppear {
						print("Name: \(name)")
					}
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
