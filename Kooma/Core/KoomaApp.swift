
import SwiftUI

@main
struct KoomaApp: App {
	@AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    var body: some Scene {
        WindowGroup {
			NavigationStack {
				if self.hasCompletedOnboarding {
					YourNextRoomView()
				} else {
					OnboardingStepOneView()
				}
			}
        }
    }
}
