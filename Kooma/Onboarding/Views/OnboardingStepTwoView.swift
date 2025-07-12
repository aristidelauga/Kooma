
import SwiftUI

struct OnboardingStepTwoView: View {
    @Binding var hasCompletedOnboarding: Bool
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

            NavigationLink(destination: CreateUserView(hasCompletedOnboarding: $hasCompletedOnboarding), label: {
				TextHeading200(text: "Get Started")
					.padding(.vertical, 20)
					.padding(.horizontal, 12)
					.frame(maxWidth: 130, maxHeight: 48)
					.background(
						RoundedRectangle(cornerRadius: 48)
							.foregroundStyle(.kmYellow)
					)
			})
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
    OnboardingStepTwoView(hasCompletedOnboarding: .constant(false))
}
