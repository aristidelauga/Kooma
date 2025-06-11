
import SwiftUI

struct CreateRoomView: View {
	@State private var roomName = ""
	@State private var roomCode = ""
	@State private var createRoomSheet = false
	@State private var path = NavigationPath()
    var body: some View {
		NavigationStack(path: $path) {
			VStack(alignment: .leading, spacing: 0) {
				TextHeading600(text: "Room details")
				KMTextfield(text: $roomName, placeholder: "Name your room")
					.padding(.vertical, 16)

				VStack {
					MainButton(text: "Create Room", maxWidth: 140) {
						createRoomSheet = true
					}
					.frame(maxWidth: .infinity, alignment: .trailing)
				}

				TextHeading600(text: "Join a Room")
					.padding(.top, 60)

				KMTextfield(text: $roomCode, placeholder: "Enter Room Code")
					.padding(.vertical, 16)

				NavigationLink(destination: ResearchRoomView(navigationPath: $path)) {
					Button {
						path.append("ResearchRoomView")
					} label: {
						TextHeading200(text: "Continue")
							.padding(.vertical, 20)
							.padding(.horizontal, 12)
							.frame(maxWidth: 112, maxHeight: 48)
							.background(
								RoundedRectangle(cornerRadius: 48)
									.foregroundStyle(.kmYellow)
							)
					}
				}
				.frame(maxWidth: .infinity, alignment: .trailing)
				Spacer()
			}
			.padding(.horizontal, 16)
			.navigationTitle("Create a room")
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
    	CreateRoomView()
    }
}
