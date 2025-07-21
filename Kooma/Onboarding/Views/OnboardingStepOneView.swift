
import SwiftUI

struct OnboardingStepOneView: View {
    var navigationVM: NavigationViewModel
    var body: some View {
		VStack(spacing: 0) {
			Image(.onboarding1)
				.resizable()
				.frame(maxWidth: .infinity, maxHeight: 220)
                .imageScale(.large)
            TextHeading800(text: "Lunch decisions, made \n easy")
				.multilineTextAlignment(.center)
				.padding(.top, 20)
				.padding(.bottom, 16)
			TextBodyLarge(text: "Quickly and easily decide where to have lunch")
			Spacer()

            Button {
                self.navigationVM.goToOnboardingStepTwoView()
            } label: {
                NavigationButton(text: "Continue")
            }
        }
		.background(
			Color.kmBeige
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.edgesIgnoringSafeArea(.all)
		)
    }
}

#Preview {
    OnboardingStepOneView(navigationVM: NavigationViewModel())
}
