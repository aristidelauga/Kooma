
import SwiftUI

struct RoomDetailCell: View {
    @State var restaurant: RestaurantUI
    @Binding var room: RoomUI
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
