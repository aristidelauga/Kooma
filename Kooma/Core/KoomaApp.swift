
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
                    case AppRoute.yourNextRoom(let hasRooms):
                        YourNextRoomView(userManager: userManager, hasRooms: hasRooms)
                    case AppRoute.roomsList:
                        RoomsListView(service: self.service)
                    case AppRoute.roomDetails(let roomID):
                        if let user = self.userManager.currentUser {
                            RoomDetailsLoaderView(
                                roomID: roomID,
                                user: user,
                                service: self.service,
                                navigationVM: self.navigationVM
                            )
                            .navigationBarBackButtonHidden()
                        }
                    case .addressSearch(let room):
                        SearchAddressView(room: room, service: service, navigationVM: self.navigationVM)
                    case .radiusSettingView(let room):
                        RadiusSettingView(room: room, service: self.service, navigationVM: self.navigationVM)
                    case .RoomSearch(code: let code):
                        ResearchRoomView(
                            service: self.service,
                            code: code,
                            userManager: self.userManager,
                            navigationVM: self.navigationVM
                        )
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .onAppear {
                Task {
                    if let currentUserID = self.userManager.currentUser?.id {
                        self.service.startListening(forUserID: currentUserID)
                    }
                    try await Task.sleep(for: .seconds(3))
                    self.isLoading = false
                }
            }
            .onDisappear {
                self.service.stopListening()
            }
        }
        .environment(self.service)
        .environment(self.userManager)
        .environment(self.navigationVM)
    }
}
