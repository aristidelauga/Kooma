
import SwiftUI

struct RoomDetailsView: View {
    @State private var roomDetailsVM = RoomDetailsViewModel()
    var room: RoomUI
    var body: some View {
        VStack {
            ForEach(room.restaurants) { restaurant in
                RoomDetailCell(restaurant: restaurant)
            }
        }
        .navigationTitle(room.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
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
        )
    )
}
