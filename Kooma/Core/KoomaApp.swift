
import SwiftUI
import FirebaseCore
import Firebase
import FirebaseFirestore


@main
struct KoomaApp: App {
    @State private var userManager = UserManager()
    @State private var navigationVM = NavigationViewModel()
    @State private var service = FirestoreService()
    @State private var launchAppVM = LaunchAppViewModel()
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
                                self.launchAppVM = LaunchAppViewModel(service: self.service)
                            }
                    } else if self.userManager.currentUser != nil {
                        switch !self.launchAppVM.myRooms.isEmpty || !self.launchAppVM.joinedRooms.isEmpty {
                        case true:
                            RoomsListView(service: self.service)
                        case false:
                            YourNextRoomView(userManager: self.userManager)
                        }
                    } else {
                        OnboardingStepOneView(navigationVM: self.navigationVM)
                    }
                }
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case AppRoute.onboardingStepTwo:
                        OnboardingStepTwoView(navigationVM: self.navigationVM)
                    case AppRoute.createUserView:
                        CreateUserView(navigationVM: self.navigationVM)
                    case AppRoute.yourNextRoom(let hasRooms):
                        YourNextRoomView(userManager: userManager, hasRooms: hasRooms)
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
                    case AppRoute.roomsList:
                        RoomsListView(service: self.service)
                    case AppRoute.roomDetails(let room):
                        if let user = self.userManager.currentUser {
                            RoomDetailsView(
                                room: room,
                                user: user,
                                service: self.service,
                                navigation: self.navigationVM
                            )
//                            .navigationBarBackButtonHidden()
                        }
                    case .restaurantDetail(let names, let restaurant):
                        RestaurantDetailView(navigationVM: self.navigationVM, restaurant: restaurant, names: names)
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .onAppear {
                Task {
                    if let currentUserID = self.userManager.currentUser?.id {
                        try await self.launchAppVM.getMyRoomsConverted(userID: currentUserID)
                        try await self.launchAppVM.getJoinedRoomsConverted(userID: currentUserID)
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
