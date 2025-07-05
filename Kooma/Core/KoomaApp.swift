
import SwiftUI
import FirebaseCore
import Firebase
import FirebaseFirestore


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
                Group {
                    if self.hasCompletedOnboarding, let user = self.userManager.currentUser {
                        if self.roomsListVM.rooms.isEmpty || !self.navigationVM.showRoomsList {
                            YourNextRoomView(user: user)
                        } else {
                            RoomsListView()
                        }
                    } else {
                        OnboardingStepOneView()
                    }
                }
                .navigationDestination(for: AppRoute.self) { route in
//                    if route == AppRoute.yourNextRoom, let user = self.userManager.currentUser {
//                        YourNextRoomView(user: user)
//                    }
                    switch route {
                    case AppRoute.yourNextRoom:
                        if let user = self.userManager.currentUser {
                            YourNextRoomView(user: user)
                        }
                    case AppRoute.roomsList:
                        RoomsListView()
                    }
                }
//                .navigationDestination(isPresented: $navigationVM.showRoomsList, destination: {
//                    RoomsListView()
//                })
                .onAppear {
                    print("current state of hasCompletedOnboarding: \(self.hasCompletedOnboarding)")
                }
            }
            .navigationBarBackButtonHidden()
        }
        .environment(self.userManager)
        .environment(self.roomsListVM)
        .environment(self.navigationVM)
    }
}
