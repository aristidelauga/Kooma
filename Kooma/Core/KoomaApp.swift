
import SwiftUI
import FirebaseCore
import Firebase
import FirebaseFirestore


@main
struct KoomaApp: App {
    @State private var userManager = UserManager()
    @State private var navigationVM = NavigationViewModel()
    @State private var service = FirestoreService()
    @State private var isLoading = true
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
                                print("self.service.rooms.isEmpty: \(self.service.myRooms.isEmpty)")
                            }
                    } else if self.userManager.currentUser != nil {
                        switch !self.service.myRooms.isEmpty || !self.service.joinedRooms.isEmpty {
                            case true:
                            RoomsListView(service: self.service)
                            case false:
                            YourNextRoomView(userManager: self.userManager)
                            }
                        } else {
                            OnboardingStepOneView()
                    }
                }
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case AppRoute.yourNextRoom:
                            YourNextRoomView(userManager: userManager)
                    case AppRoute.roomsList:
                        RoomsListView(service: self.service)
                    case AppRoute.roomDetails(let roomID):
                        if let user = self.userManager.currentUser, let room = self.service.getRoomByID(roomID, userID: user.id) {
                            RoomDetailsView(
                                room: room,
                                user: user,
                                service: service,
                                navigation: navigationVM
                            )
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .onAppear {
                Task {
                    if let currentUserID = self.userManager.currentUser?.id {
                        try await self.service.fetchMyRooms(withUserID: currentUserID)
                        try await self.service.fetchJoinedRooms(withUserID: currentUserID)
                    }
                    try await Task.sleep(for: .seconds(3))
                    self.isLoading = false
                }
            }
        }
        .environment(self.service)
        .environment(self.userManager)
        .environment(self.navigationVM)
    }
}
