
import SwiftUI

struct CreateUserView: View {
	@State private var createUserVM = CreateUserViewModel()
    @State var placeholder: String = "Enter your name"
    @Environment(UserManager.self) private var userManager
    var navigationVM: NavigationViewModel
    var body: some View {
		VStack(alignment: .leading) {
        	TextHeading600(text: "Your name")
			KMTextfield(text: $createUserVM.name, placeholder: placeholder)

            Button {
                self.createUserVM.createUser()
                if !self.createUserVM.name.isEmpty {
                    if let user = self.createUserVM.user {
                        self.userManager.setUser(user)
                    }
                    self.navigationVM.goToYourNextRoomViewFromUserCreation()
                } else {
                    placeholder = "You must enter a name to continue"
                }
            } label: {
                NavigationButton(text: "Submit")
                    .padding(.top, 18)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
		.padding(.horizontal, 16)
		.navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.kmBeige)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    CreateUserView(navigationVM: NavigationViewModel())
        .environment(FirestoreService())
        .environment(UserManager())
}
