
import SwiftUI

struct ResearchRoomView: View {
	@State private var isLoading: Bool = false
    @State private var viewModel: ResearchRoomViewModel
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var service: FirestoreService
    var userManager: UserManager
    var navigatioNVM: NavigationViewModel
    var code: String
    @State private var popupError: Error?
    init(service: FirestoreService, code: String, userManager: UserManager, navigationVM: NavigationViewModel) {
        self.service = service
        self.code = code
        self.userManager = userManager
        self.navigatioNVM = navigationVM
        _viewModel = State(wrappedValue: ResearchRoomViewModel(service: service))
    }
    var body: some View {
		ZStack {
            if let error = self.popupError {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                PopupError(error: error as! JoinRoomError) {
                    popupError = nil
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
            VStack {
                Spacer()
                HStack {
                    TextHeading400(text: "Looking for your room")
                    ThreeDotsView(loading: $isLoading)
                        .padding(.top, 10)
                }
                Spacer()

                MainButton(text: "Cancel") {
                    self.presentationMode.wrappedValue.dismiss()
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
                        navigatioNVM.showRoomsListView()
                        do {
                            try await self.viewModel.joinRoom(code: self.code, user: user)
                        } catch {
                            self.popupError = error
                        }
                    }
//                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

//#Preview {
//    ResearchRoomView(service: FirestoreService(), code: "EXPD33", userManager: UserManager())
//}


