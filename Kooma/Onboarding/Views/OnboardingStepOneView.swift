
import SwiftUI

struct OnboardingStepOneView: View {
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

			NavigationLink(destination: OnboardingStepTwoView(), label: {
//				TextHeading200(text: "Continue")
//					.padding(.vertical, 20)
//					.padding(.horizontal, 12)
//					.frame(maxWidth: 112, maxHeight: 48)
//					.background(
//						RoundedRectangle(cornerRadius: 48)
//							.foregroundStyle(.kmYellow)
//					)
				NavigationButton(text: "Continue")
			})
        }
		.background(
			Color.kmBeige
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.edgesIgnoringSafeArea(.all)
		)
    }
}

#Preview {
	OnboardingStepOneView()
}
