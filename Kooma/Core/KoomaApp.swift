
import SwiftUI
import FirebaseCore
import Firebase
import FirebaseFirestore


@main
struct KoomaApp: App {
    @MainActor @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var userManager = UserManager()
    @State private var navigationVM = NavigationViewModel()
    @State private var service = FirestoreService()
    @State private var isLoading = true
    @State private var displayYourNextRoomView: Bool = false
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationVM.path) {
                VStack {
                    if self.isLoading {
                       LaunchScreenView()
                            .onAppear {
                                print("self.service.rooms.isEmpty: \(self.service.rooms.isEmpty)")
                            }
                    } else if self.hasCompletedOnboarding {
//                        if self.hasCompletedOnboarding {
//                            if self.service.rooms.isEmpty {
//                                YourNextRoomView(userManager: UserManager())
//                            } else {
//                                RoomsListView()
//                            }
                            switch self.service.rooms.isEmpty {
                            case true:
                                YourNextRoomView(userManager: userManager)
                            case false:
                                RoomsListView(service: self.service)
                            }
                        } else {
                            OnboardingStepOneView(hasCompletedOnboarding: $hasCompletedOnboarding)
//                        }
                    }
                }
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case AppRoute.yourNextRoom:
                            YourNextRoomView(userManager: UserManager())
                    case AppRoute.roomsList:
                        RoomsListView(service: self.service)
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .onAppear {
//                print("hasCompletedOnboarding: \(self.hasCompletedOnboarding)")
                Task { @MainActor in
                    try await self.service.fetchRooms()
                    try await Task.sleep(for: .seconds(3))
                    displayYourNextRoomView = self.service.rooms.isEmpty
                    self.isLoading = false
                }
            }
            
//            .onChange(of: self.service.rooms.isEmpty, initial: true) {
//                print("self.service.roomsIsEmpty: \(self.service.rooms.isEmpty)")
//                self.isLoading = false
//            }
        }
        .environment(self.service)
        .environment(self.userManager)
        .environment(self.navigationVM)
    }
}
