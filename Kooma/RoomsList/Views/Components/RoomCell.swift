
import SwiftUI

struct RoomCell: View {
	var room: RoomUI
    var body: some View {
		VStack(alignment: .leading) {
            if let image = room.image {
                Image(image)
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: 140)
                    .cornerRadius(12, corners: [.topLeft, .topRight])
                
            }

			VStack(alignment: .leading, spacing: 6){
				TextHeading600(text: room.name ?? "Work Lunch Room")
                
                Text(.init("**\(self.room.administrator.name)** is the administrator"))
                    .font(.bodyLarge)
                    .foregroundStyle(.kmBlack)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("^[\(self.room.members.count) member](inflect: true)")
                    .font(.bodyMedium)
                    .foregroundStyle(.kmKaki)
                    .padding(.bottom, 12)

			}
            .padding(.horizontal, 8)
		}
        .frame(maxWidth: 250)
		.background(
			RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.kmBeige)
                .shadow(color: .kmBlack.opacity(0.2), radius: 2, x: 12, y: 5)
		)
    }
}

#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack {
            RoomCell(
                room: RoomUI(
                    id: "12b489",
                    name: "Mobile Tech and Product and Design Squads",
					administrator: UserUI(id: UUID().uuidString, name: "KawabungaDelToro")
                )
            )
            .padding(.trailing)
        }
        .padding(.vertical)
    }
}
