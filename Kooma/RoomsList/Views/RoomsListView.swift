
import SwiftUI

struct RoomsListView: View {
    @State private var roomsListVM = RoomsListViewModel(firestoreService: FirestoreService())
    @Environment(NavigationViewModel.self) private var navigationVM
    @Environment(UserManager.self) private var userManager
    @State private var room: RoomUI?
    var service: FirestoreService
    init(service: FirestoreService) {
        self.service = service
        _roomsListVM = State(wrappedValue: RoomsListViewModel(firestoreService: service))
    }
    
    var body: some View {
        VStack {
            TextHeading600(text: "Your Rooms")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 12)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(self.roomsListVM.myRooms) { room in
                            Button {
                                self.navigationVM.path.append(AppRoute.roomDetails(roomID: room.id ?? ""))
                            } label: {
                                RoomCell(room: room)
                            }
                    }
                    .padding(.bottom, 12)
                }
            }
            .padding(12)
            
            
            TextHeading600(text: "Rooms you are invited")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 12)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(self.roomsListVM.joinedRooms) { room in
                        Button {
                            //TODO: Add to NavigationVM
                            self.navigationVM.path.append(AppRoute.roomDetails(roomID: room.id ?? ""))
                        } label: {
                            RoomCell(room: room)
                        }
                    }
                }
                .padding(.bottom, 12)
            }
            .padding(12)
            Spacer()
            
            MainButton(text: "New Room", maxWidth: 142) {
                let hasRooms = !self.roomsListVM.joinedRooms.isEmpty || !self.roomsListVM.myRooms.isEmpty
                self.navigationVM.goToYourNextRoomView(hasRooms: hasRooms)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 38)
        }
        .onAppear {
            Task {
                if let userID = self.userManager.currentUser?.id {
                    try await self.roomsListVM.getMyRoomsConverted(userID: userID)
                    try await self.roomsListVM.getJoinedRoomsConverted(userID: userID)
                }
            }
        }
        .background(
            Color.kmBeige
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationTitle("Rooms")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    RoomsListView(service: FirestoreService())
        .environment(RoomsListViewModel(firestoreService: FirestoreService()))
		.environment(UserManager())
        .environment(NavigationViewModel())
}
