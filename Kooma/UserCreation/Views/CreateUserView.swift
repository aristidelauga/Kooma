
import SwiftUI

struct CreateUserView: View {
	@State private var createUserVM = CreateUserViewModel()
    @MainActor @Binding var hasCompletedOnboarding: Bool
	@Environment(UserManager.self) private var userManager
    var body: some View {
		VStack(alignment: .leading) {
        	TextHeading600(text: "Your name")
			KMTextfield(text: $createUserVM.name)
			MainButton(text: "Submit") { @MainActor in
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
                    YourNextRoomView(userManager: self.userManager)
				}
			})
        }
		.padding(.horizontal, 16)
		.navigationBarBackButtonHidden()
    }
}

#Preview {
    CreateUserView(hasCompletedOnboarding: .constant(false))
}
