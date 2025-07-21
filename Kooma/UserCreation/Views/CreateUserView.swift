
import SwiftUI

struct CreateUserView: View {
	@State private var createUserVM = CreateUserViewModel()
	@Environment(UserManager.self) private var userManager
    var navigationVM: NavigationViewModel
    var body: some View {
		VStack(alignment: .leading) {
        	TextHeading600(text: "Your name")
			KMTextfield(text: $createUserVM.name)

            Button {
                self.createUserVM.createUser()
                if let user = self.createUserVM.user {
                    self.userManager.setUser(user)
                }
                self.navigationVM.goToYourNextRoomViewFromUserCreation()
                print("Path: \(self.navigationVM.path)")
            } label: {
                NavigationButton(text: "Submit")
                    .padding(.top, 18)
                    .frame(maxWidth: .infinity, alignment: .trailing)

            }
        }
		.padding(.horizontal, 16)
		.navigationBarBackButtonHidden()
    }
}

#Preview {
    CreateUserView(navigationVM: NavigationViewModel())
        .environment(FirestoreService())
        .environment(UserManager())
}
