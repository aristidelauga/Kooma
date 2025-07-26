
import SwiftUI

struct ResearchRoomView: View {
	@State private var isLoading: Bool = false
    @State private var viewModel: ResearchRoomViewModel
    @State private var popupError: Error?
    var service: FirestoreService
    var userManager: UserManager
    var navigationVM: NavigationViewModel
    var code: String
    var hasRooms: Bool
    init(service: FirestoreService, code: String, userManager: UserManager, navigationVM: NavigationViewModel, hasRooms: Bool) {
        self.service = service
        self.code = code
        self.userManager = userManager
        self.navigationVM = navigationVM
        self.hasRooms = hasRooms
        _viewModel = State(wrappedValue: ResearchRoomViewModel(service: service))
    }
    var body: some View {
		ZStack {
            VStack {
                Spacer()
                HStack {
                    TextHeading400(text: "Looking for your room")
                    ThreeDotsView(loading: $isLoading)
                        .padding(.top, 10)
                }
                Spacer()

                MainButton(text: "Cancel") {
                    self.navigationVM.goToYourNextRoomView(hasRooms: hasRooms)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Color.kmBeige
                    .edgesIgnoringSafeArea(.all)
            )
            .navigationBarBackButtonHidden()
            .onAppear {
                Task {
                    if let user = self.userManager.currentUser {
                        try await self.viewModel.fetchJoinedRooms(userID: user.id)
                        do {
                            try await self.viewModel.joinRoom(code: self.code, user: user)
                            navigationVM.showRoomsListView()
                        } catch {
                            self.popupError = error
                        }
                    }
                }
            }
            if let error = self.popupError {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                PopupError(error: error as! JoinRoomError) {
                    popupError = nil
                    self.navigationVM.goToYourNextRoomView(hasRooms: hasRooms)
                }
            }
        }
    }
}
