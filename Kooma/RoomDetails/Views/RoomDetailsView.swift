
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
                VStack(alignment: .leading, spacing: 12) {
                    TextHeading600(text: "Room info")
                    HStack(spacing: 0) {
                        TextHeading200(text: "Room code: ")
                        Text(.init("**\(self.roomDetailsVM.currentRoom.code)**"))
                            .font(.bodyLarge)
                            .foregroundColor(.KMYellow)
                    }
                    
                    if let address = self.roomDetailsVM.currentRoom.address {
                        Text(.init("**Room address:** ")) + Text(address)
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
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                TextHeading600(text: "Restaurants")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(self.roomDetailsVM.currentRoom.restaurants) { restaurant in
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            TextHeading200(text: restaurant.name)
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
                        }
                    }
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
        }
        .onDisappear(perform: {
            self.roomDetailsVM.endListening()
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

#Preview {
    NavigationStack {
        RoomDetailsView(
            room: RoomUI(
                id: "1-43432jf49fgjjf",
                hostID: "1-942hfd3410]fh8]",
                code: "BBX8TR93",
                name: "Friends",
                administrator: UserUI(id: "1-942hfd3410]fh8]", name: "Ross Geller"),
                address: "90 Bedford Street, New-York",
                members: [
                    UserUI(id: "fbn341fu8h13[f4gh", name: "Chandler Bing"),
                    UserUI(id: "qegertgrtgr[f4gh", name: "Monica Geller"),
                    UserUI(id: "rtgrtwg[rgtrwtgtrwgrtw", name: "Phoebe Buffay"),
                    
                ],
                restaurants: [
                    RestaurantUI(
                        id: "0df48hf134hf0",
                        name: "Central Perk",
                        phoneNumber: "+49 612-345-678",
                        address: "90 Bedford Street, New-York",
                        url: "https://centralparktoursnyc.com/central-perk-coffee-shop/"),
                    RestaurantUI(
                        id: "0df48hf134hf0",
                        name: "Central Perk",
                        phoneNumber: "+49 612-345-678",
                        address: "90 Bedford Street, New-York",
                        url: "https://centralparktoursnyc.com/central-perk-coffee-shop/"),
                    RestaurantUI(
                        id: "0df48hf134hf0",
                        name: "Central Perk",
                        phoneNumber: "+49 612-345-678",
                        address: "90 Bedford Street, New-York",
                        url: "https://centralparktoursnyc.com/central-perk-coffee-shop/",),
                ],
                votes: ["": ["", ""]], image: ""
            ),
            user: UserUI(id: "f480808hd8", name: "Gustave"),
            service: FirestoreService(), navigation: NavigationViewModel()
        )
    }
}
