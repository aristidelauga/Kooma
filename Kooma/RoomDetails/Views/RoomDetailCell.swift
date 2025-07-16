
import SwiftUI

struct RoomDetailCell: View {
//    var voteTracker: VoteTracker
    var restaurant: RestaurantUI
    var voteAction: () -> Void
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                TextHeading200(text: restaurant.name)
                Text("^[\(restaurant.vote) vote](inflect: true)")
                    .font(.bodyMedium)
                    .foregroundStyle(.kmKaki)
            }
            Spacer()
            Button {
                voteAction()
            } label: {
//                Image(voteTracker.hasVoted(restaurant) ? .thumbFill : .thumbEmpty)
                Image(.thumbEmpty)
                    .resizable()
                    .frame(maxWidth: 24, maxHeight: 24)
            }
            
        }
    }
}

#Preview {
    RoomDetailCell(
        /*voteTracker: VoteTracker(),*/ restaurant: RestaurantUI(
            id: "0df48hf134hf0",
            name: "Central Perk",
            phoneNumber: "+49 612-345-678",
            address: "90 Bedford Street, New-York",
            url: "https://centralparktoursnyc.com/central-perk-coffee-shop/",
            vote: 0),
        voteAction: {}
    )
}
