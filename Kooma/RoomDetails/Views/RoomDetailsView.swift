
import SwiftUI

struct RoomDetailsView: View {
    @State private var roomDetailsVM = RoomDetailsViewModel()
//    @State private var voteTracker = VoteTracker()
    var navigationVM: NavigationViewModel
    var room: RoomUI
    var user: UserUI
    init(room: RoomUI, user: UserUI, service: FirestoreService, navigation: NavigationViewModel) {
        self.room = room
        self.user = user
        self.navigationVM = navigation
        _roomDetailsVM = State(wrappedValue: RoomDetailsViewModel(service: service))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            TextHeading600(text: "Restaurants")
                .padding(.leading, 12)
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(room.restaurants) { restaurant in
                    RoomDetailCell(
//                        voteTracker: self.voteTracker,
                        restaurant: restaurant
                    ) {
                        Task {
                           try await roomDetailsVM.vote(
                                    forRestaurant: restaurant,
                                    inRoom: self.room,
                                    user: self.user
                                )
//                            voteTracker.setVoted(restaurant)
                        }
                    }
                }
                .padding(.horizontal, 12)
            }
            TextHeading600(text: "\(room.code)")
                .padding(.leading, 12)
        }
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
            print("self.room.votes: \(self.room.votes)")
        }
        .background(
            Color.kmBeige
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationTitle(room.name ?? "")
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        RoomDetailsView(
            room: RoomUI(
                id: "1-43432jf49fgjjf",
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
                        url: "https://centralparktoursnyc.com/central-perk-coffee-shop/",
                        vote: 0),
                    RestaurantUI(
                        id: "0df48hf134hf0",
                        name: "Central Perk",
                        phoneNumber: "+49 612-345-678",
                        address: "90 Bedford Street, New-York",
                        url: "https://centralparktoursnyc.com/central-perk-coffee-shop/",
                        vote: 0),
                    RestaurantUI(
                        id: "0df48hf134hf0",
                        name: "Central Perk",
                        phoneNumber: "+49 612-345-678",
                        address: "90 Bedford Street, New-York",
                        url: "https://centralparktoursnyc.com/central-perk-coffee-shop/",
                        vote: 0),
                ]
            ),
            user: UserUI(id: "f480808hd8", name: "Gustave"),
            service: FirestoreService(), navigation: NavigationViewModel()
        )
    }
}

//@Observable @MainActor
//final class VoteTracker {
//    var votedRestaurantIDs: Set<String> = []
//    
//    func hasVoted(_ restaurant: RestaurantUI) -> Bool {
//        votedRestaurantIDs.contains(restaurant.id)
//    }
//    
//    func setVoted(_ restaurant: RestaurantUI) {
//        votedRestaurantIDs.insert(restaurant.id)
//    }
//    
//    func preloadVotes(from room: RoomUI, user: UserUI) {
//        var voted = Set<String>()
//        for (restaurantID, userIDs) in room.votes {
//            if userIDs.contains(user.id) {
//                voted.insert(restaurantID)
//            }
//        }
//        self.votedRestaurantIDs = voted
//    }
//}
