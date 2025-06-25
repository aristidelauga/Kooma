
import SwiftUI

@main
struct KoomaApp: App {
	@AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
	@State private var userManager = UserManager()
	@State private var roomsListVM = RoomsListViewModel()
    var body: some Scene {
        WindowGroup {
			NavigationStack {
				if self.hasCompletedOnboarding, let user = self.userManager.currentUser {
					YourNextRoomView(user: user)
				} else {
					OnboardingStepOneView()
				}
			}
        }
		.environment(self.userManager)
		.environment(self.roomsListVM)
    }
}
