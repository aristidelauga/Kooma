
import SwiftUI

struct CreateUserView: View {
	@State private var createUserVM = CreateUserViewModel()
	@AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
	@Environment(UserManager.self) private var userManager
    var body: some View {
		VStack(alignment: .leading) {
        	TextHeading600(text: "Your name")
			KMTextfield(text: $createUserVM.name)
			MainButton(text: "Submit") {
				self.createUserVM.createUser()
				if let user = self.createUserVM.user {
					self.userManager.setUser(user)
				}
				self.hasCompletedOnboarding = true
			}
			.padding(.top, 18)
			.frame(maxWidth: .infinity, alignment: .trailing)
			.navigationDestination(isPresented: $hasCompletedOnboarding, destination: {
				if let user = self.createUserVM.user {
					YourNextRoomView(user: user)
				}
			})
        }
		.padding(.horizontal, 16)
		.navigationBarBackButtonHidden()
    }
}

#Preview {
	CreateUserView()
}
