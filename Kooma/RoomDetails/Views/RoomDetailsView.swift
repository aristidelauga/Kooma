
import SwiftUI

struct RoomDetailsView: View {
    var room: RoomUI
    var body: some View {
        VStack {
            ForEach(room.restaurants ?? []) { restaurant in
                Text(restaurant.address)
            }
        }
    }
}

#Preview {
    RoomDetailsView(
        room: RoomUI(
            id: "21094",
            name: "One",
            administrator: UserUI(id: "12049120585235", name: "Admin")
        )
    )
}
