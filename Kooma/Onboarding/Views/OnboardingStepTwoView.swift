
import SwiftUI

struct OnboardingStepTwoView: View {
    var navigationVM: NavigationViewModel
	var body: some View {
		VStack(spacing: 0) {
			Image(.onboarding2)
				.resizable()
				.frame(maxWidth: .infinity, maxHeight: 220)
				.imageScale(.large)
			VStack {
				TextHeading800(text: "Ready to plan your next lunch?")
					.multilineTextAlignment(.center)
					.padding(.top, 20)
					.padding(.bottom, 16)
				TextBodyLarge(text: "Create a group or join an existing one to start planning your next lunch with your coworkers and friends.")
					.multilineTextAlignment(.center)
			}
			.padding(.horizontal, 16)
			Spacer()

            Button {
                self.navigationVM.goToCreateUserView()
            } label: {
                NavigationButton(text: "Get Started")
            }
		}
		.background(
			Color.kmBeige
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.edgesIgnoringSafeArea(.all)
		)
		.navigationBarBackButtonHidden()
	}
}

#Preview {
    OnboardingStepTwoView(navigationVM: NavigationViewModel())
}
