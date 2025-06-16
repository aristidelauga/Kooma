
import SwiftUI

struct CreateUserView: View {
	@State private var username: String = ""
	@AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    var body: some View {
		VStack(alignment: .leading) {
        	TextHeading600(text: "Your name")
			KMTextfield(text: $username)
			MainButton(text: "Submit") {
				self.hasSeenOnboarding = true
			}
			.padding(.top, 18)
			.frame(maxWidth: .infinity, alignment: .trailing)
			.navigationDestination(isPresented: $hasSeenOnboarding, destination: {
				YourNextRoomView()
			})
        }
		.padding(.horizontal, 16)
		.navigationBarBackButtonHidden()
    }
}

#Preview {
    CreateUserView()
}
