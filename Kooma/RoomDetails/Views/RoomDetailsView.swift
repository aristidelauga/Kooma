
import SwiftUI

struct RoomDetailsView: View {
    var room: RoomUI
    var body: some View {
        VStack {
//            ForEach(room.restaurants ?? []) { restaurant in
//                Text(restaurant.address)
//            }
            Text(room.code)
            ForEach(room.members ?? []) { member in
                Text(member.name)
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
