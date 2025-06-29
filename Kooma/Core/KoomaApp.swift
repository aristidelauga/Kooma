
import SwiftUI
import FirebaseCore

@main
struct KoomaApp: App {
	@AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
	@State private var roomsListVM = RoomsListViewModel()
	@State private var userManager = UserManager()
	@State private var navigationVM = NavigationViewModel()

	init() {
		FirebaseApp.configure()
	}

    var body: some Scene {
        WindowGroup {
			NavigationStack(path: $navigationVM.path) {
				if self.hasCompletedOnboarding, let user = self.userManager.currentUser {
					if self.roomsListVM.rooms.isEmpty {
						YourNextRoomView(user: user)
					} else {
						RoomsListView()
					}
				} else {
					OnboardingStepOneView()
				}
			}
        }
		.environment(self.userManager)
		.environment(self.roomsListVM)
		.environment(self.navigationVM)
    }
}
