
import SwiftUI

struct RoomDetailCell: View {
    //    var voteTracker: VoteTracker
    @State var restaurant: RestaurantUI
    @Binding var room: RoomUI
//    @State var hasVoted: Bool = false
    var voteAction: () -> Void
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                TextHeading200(text: restaurant.name)
                Text("^[\(String(describing: room.votes[restaurant.id]?.count)) vote](inflect: true)")
                    .font(.bodyMedium)
                    .foregroundStyle(.kmKaki)
            }
            Spacer()
            Button {
                voteAction()
            } label: {
                Image(.thumbFill)
                    .resizable()
                    .frame(maxWidth: 24, maxHeight: 24)
            }
        }
    }
}

#Preview {
    RoomDetailCell(
        restaurant: RestaurantUI(
            id: "0df48hf134hf0",
            name: "Central Perk",
            phoneNumber: "+49 612-345-678",
            address: "90 Bedford Street, New-York",
            url: "https://centralparktoursnyc.com/central-perk-coffee-shop/"),
        room: .constant(RoomUI(administrator: UserUI(id: "", name: ""))),
        voteAction: {}
    )
}
