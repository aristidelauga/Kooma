
import SwiftUI

struct RoomsListView: View {
    @State private var roomsListVM: RoomsListViewModel
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
            if self.roomsListVM.myRooms.isEmpty {
                VStack(alignment: .center) {
                    Image(.emptyRoomsState)
                        .resizable()
                        .clipShape(Circle())
                        .scaledToFit()
                        .frame(maxWidth: 250)
                    TextBodyMedium(text: "You have created no rooms yet.")
                        .padding(.top, 6)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 18)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(self.roomsListVM.myRooms) { room in
                            Button {
                                self.navigationVM.path.append(AppRoute.roomDetails(room: room))
                            } label: {
                                RoomCell(room: room)
                            }
                        }
                        .padding(.bottom, 12)
                    }
                }
                .padding(12)
            }
            
            
            TextHeading600(text: "Rooms you are invited")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 12)
            
            if self.roomsListVM.joinedRooms.isEmpty {
                VStack(alignment: .center) {
                    Image(.emptyRoomsState)
                        .resizable()
                        .clipShape(Circle())
                        .scaledToFit()
                        .frame(maxWidth: 250)
                        .padding(.top, 18)
                    TextBodyMedium(text: "You have joined no rooms yet.")
                        .padding(.horizontal, 66)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(self.roomsListVM.joinedRooms) { room in
                            Button {
                                //TODO: Add to NavigationVM
                                self.navigationVM.path.append(AppRoute.roomDetails(room: room))
                            } label: {
                                RoomCell(room: room)
                            }
                        }
                    }
                    .padding(.bottom, 12)
                }
                .padding(12)
            }
            Spacer()
            
            MainButton(text: "New Room", maxWidth: 142) {
                let hasRooms = !self.roomsListVM.joinedRooms.isEmpty || !self.roomsListVM.myRooms.isEmpty
                self.navigationVM.goToYourNextRoomView(hasRooms: hasRooms)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 38)
        }
        .navigationTitle("Rooms")
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .background(
            Color.kmBeige
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
        )
        
        .onAppear {
            Task {
                if let userID = self.userManager.currentUser?.id {
                    self.roomsListVM.startListening(forUserID: userID)
                }
            }
        }
        .onDisappear {
            self.roomsListVM.endListening()
        }

    }
}

#Preview {
    RoomsListView(service: FirestoreService())
        .environment(RoomsListViewModel(firestoreService: FirestoreService()))
        .environment(UserManager())
        .environment(NavigationViewModel())
}
