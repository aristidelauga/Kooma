
import SwiftUI

struct RoomDetailsView: View {
    @State private var roomDetailsVM: RoomDetailsViewModel
    var navigationVM: NavigationViewModel
    var user: UserUI
    init(room: RoomUI, user: UserUI, service: FirestoreService, navigation: NavigationViewModel) {
        self.user = user
        self.navigationVM = navigation
        _roomDetailsVM = State(wrappedValue: RoomDetailsViewModel(service: service, currentRoom: room))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    TextHeading600(text: "Room info")
                    HStack(spacing: 0) {
                        TextHeading200(text: "Room code: ")
                        Text(.init("**\(self.roomDetailsVM.currentRoom.code)**"))
                            .font(.bodyLarge)
                            .foregroundColor(.KMYellow)
                    }
                    
                    if let address = self.roomDetailsVM.currentRoom.address {
                        Text(.init("**Room address:** ")).font(.bodyLarge) + Text(address).font(.bodyLarge)
                    }
                    
                    TextHeading200(text: "Room members:")
                    ForEach(self.roomDetailsVM.currentRoom.members) { member in
                        if member.id == self.roomDetailsVM.currentRoom.hostID {
                            Text(.init("\(member.name) **(admin)**"))
                                .font(.bodyMedium)
                        } else {
                            TextBodyMedium(text: member.name)
                        }
                    }
                }
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                TextHeading600(text: "Restaurants")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(self.roomDetailsVM.currentRoom.restaurants) { restaurant in
                     Button {
                         let names = self.roomDetailsVM.getVotersNames(for: restaurant.id)
                         self.navigationVM.goToRestaurantDetailView(withNames: names, andRestaurant: restaurant)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                TextHeading200(text: restaurant.name)
                                    .multilineTextAlignment(.leading)
                                let restaurantVotes = self.roomDetailsVM.getVoteCount(withRestaurantID: restaurant.id)
                                Text("^[\(restaurantVotes) vote](inflect: true)")
                                    .font(.bodyMedium)
                                    .foregroundStyle(.kmKaki)
                            }
                            Spacer()
                            Button {
                                Task {
                                    if !self.roomDetailsVM.hasVoted(forRestaurant: restaurant, user: self.user) {
                                        try await roomDetailsVM.vote(forRestaurant: restaurant, user: self.user)
                                    } else {
                                        try await self.roomDetailsVM.removeVote(forRestaurant: restaurant, user: self.user)
                                    }
                                }
                            } label: {
                                Image(self.roomDetailsVM.hasVoted(forRestaurant: restaurant, user: self.user) ? "thumbFill" : "thumbEmpty")
                                    .resizable()
                                    .frame(maxWidth: 24, maxHeight: 24)
                                    .padding(.trailing, 8)
                            }
                            
                            Image(systemName: "chevron.forward")
                                .resizable()
                                .bold()
                                .foregroundStyle(.kmYellow)
                            
                                .frame(maxWidth: 14, maxHeight: 18)

                        }
                    }
                }
                
                HStack {
                    Spacer()
                    
                    MainButton(text: "Leave Room", maxWidth: 130) {
                        Task {
                            try await self.roomDetailsVM.leaveRoom(user: self.user)
                            self.navigationVM.goToRoomsListViewFromRoomDetails()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    if self.user.id == self.roomDetailsVM.currentRoom.hostID {
                        Spacer()
                        MainButton(text: "Delete Room", maxWidth: 130) {
                            Task {
                                try await self.roomDetailsVM.deleteRoom(user: self.user)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 12)
        
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    self.navigationVM.showRoomsListView()
                } label: {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .foregroundStyle(.kmYellow)
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 12)
                }
            }
        })
        .onAppear {
            self.roomDetailsVM.startListening(forUserID: user.id)
            print("path count on RoomDetailView: \(self.navigationVM.path.count)")
        }
        .onDisappear(perform: {
            self.roomDetailsVM.endListening()
        })
        .onChange(of: roomDetailsVM.roomWasDeleted, perform: { wasDeleted in
            if wasDeleted {
                self.navigationVM.showRoomsListView()
            }
        })
        .background(
            Color.kmBeige
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationTitle(self.roomDetailsVM.currentRoom.name ?? "")
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
    }
}
