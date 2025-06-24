
import SwiftUI

struct CreateUserView: View {
	@State private var username: String = ""
	@AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    var body: some View {
		VStack(alignment: .leading) {
        	TextHeading600(text: "Your name")
			KMTextfield(text: $username)
			MainButton(text: "Submit") {
				self.hasCompletedOnboarding = true
			}
			.padding(.top, 18)
			.frame(maxWidth: .infinity, alignment: .trailing)
			.navigationDestination(isPresented: $hasCompletedOnboarding, destination: {
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
