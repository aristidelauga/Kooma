
import SwiftUI

struct YourNextRoomView: View {
    @State private var roomCode = ""
    @State private var createRoomPlaceholder =  "Name your room"
    @State private var joinRoomPlaceholder =  "Enter a room code"
    // MARK: ViewModels
    @State private var yourNextRoomVM: YourNextRoomViewModel
    @Environment(NavigationViewModel.self) private var navigationVM
    @Environment(FirestoreService.self) private var service
    var userManager: UserManager
    var hasRooms: Bool? = false
    
    init(userManager: UserManager, hasRooms: Bool? = false) {
        self.userManager = userManager
        self.hasRooms = hasRooms
        _yourNextRoomVM = State(wrappedValue: YourNextRoomViewModel(user: self.userManager.currentUser ?? UserUI(id: UUID().uuidString, name: "ErrorName")))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // MARK: - Create a Room
            TextHeading600(text: "Create a Room")
                .padding(.top, 25)
            KMTextfield(text: $yourNextRoomVM.name, placeholder: createRoomPlaceholder)
                .padding(.vertical, 16)
            
            VStack {
                MainButton(text: "Create Room", maxWidth: 140) {
                    if self.yourNextRoomVM.name.isEmpty {
                        createRoomPlaceholder = "You must enter a name for your room"
                    }
                    self.yourNextRoomVM.createRoomWithName(with: self.yourNextRoomVM.user)
                    if let room = self.yourNextRoomVM.room {
                        self.navigationVM.goToSearchAddressView(withRoom: room)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            // MARK: - Join a Room
            TextHeading600(text: "Join a Room")
                .padding(.top, 92)
            
            KMTextfield(text: $roomCode, placeholder: joinRoomPlaceholder, joiningTextfield: true)
                .padding(.vertical, 16)
            
            Button {
                if !self.roomCode.isEmpty {
                    if let hasRooms = hasRooms {
                        self.navigationVM.goToResearchRoomView(withRoomCode: self.roomCode, and: hasRooms)
                        self.yourNextRoomVM.sendAnalyticsForJoiningRoom()
                    }
                } else {
                    self.joinRoomPlaceholder = "You must enter a room code"
                }
                
            } label: {
                NavigationButton(text: "Join Room")
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .navigationTitle("Your Next Room")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            if let hasRooms = self.hasRooms, hasRooms {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        self.navigationVM.showRoomsListView()
                    } label: {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .foregroundStyle(.kmYellow)
                            .frame(width: 16, height: 16)
                            .padding(.trailing, 12)
                    }
                }
            }
        }
        .background(
            Color.kmBeige
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
        )

    }
}

#Preview {
    NavigationStack {
        YourNextRoomView(userManager: UserManager())
    }
}

