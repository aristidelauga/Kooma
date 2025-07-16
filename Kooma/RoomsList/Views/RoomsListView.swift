
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
//                        if let user = userManager.currentUser {
//                            NavigationLink(destination: RoomDetailsView(room: room, user: user, service: service, navigation: navigationVM), label: {
//                                RoomCell(room: room)
//                            })
                            Button {
                                self.navigationVM.path.append(AppRoute.roomDetails(room: room))
                            } label: {
                                RoomCell(room: room)
                            }
//                        }
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
//                        if let user = userManager.currentUser {
//                            NavigationLink(destination: RoomDetailsView(room: room, user: user, service: service, navigation: navigationVM), label: {
//                                RoomCell(room: room)
//                            })
//                        }
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
            Spacer()
            
            MainButton(text: "New Room", maxWidth: 142) {
                self.navigationVM.goToYourNextRoomView()
                print("navigationVM.currentView: \(self.navigationVM.path)")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 38)
        }
        .background(
            Color.kmBeige
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationTitle("Your Rooms")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
//        .navigationDestination(item: $room) { room in
//            if let user = userManager.currentUser {
//                RoomDetailsView(room: room, user: user, service: self.service, navigation: self.navigationVM)
//            }
//        }
    }
}

#Preview {
    RoomsListView(service: FirestoreService())
        .environment(RoomsListViewModel(firestoreService: FirestoreService()))
		.environment(UserManager())
        .environment(NavigationViewModel())
}
