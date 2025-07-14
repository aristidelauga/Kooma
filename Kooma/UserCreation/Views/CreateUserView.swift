
import SwiftUI

struct CreateUserView: View {
	@State private var createUserVM = CreateUserViewModel()
    @State private var hasCompletedOnboarding: Bool = false
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
                    YourNextRoomView(userManager: self.userManager)
			})
        }
		.padding(.horizontal, 16)
		.navigationBarBackButtonHidden()
    }
}

#Preview {
    CreateUserView()
}
