
import SwiftUI
import FirebaseCore
import Firebase
import FirebaseFirestore


@main
struct KoomaApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var userManager = UserManager()
    @State private var navigationVM = NavigationViewModel()
    @State private var service = FirestoreService()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationVM.path) {
                Group {
                    if self.hasCompletedOnboarding, let user = self.userManager.currentUser {
                        if self.service.rooms.isEmpty || !self.navigationVM.showRoomsList {
                            YourNextRoomView(user: user, userManager: UserManager())
                        } else {
                            RoomsListView()
                        }
                    } else {
                        OnboardingStepOneView()
                    }
                }
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case AppRoute.yourNextRoom:
                        if let user = self.userManager.currentUser {
                            YourNextRoomView(user: user, userManager: UserManager())
                        }
                    case AppRoute.roomsList:
                        RoomsListView()
                    }
                }
            }
            .navigationBarBackButtonHidden()
        }
        .environment(self.userManager)
        .environment(self.navigationVM)
    }
}
