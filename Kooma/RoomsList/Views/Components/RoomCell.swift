
import SwiftUI

struct RoomCell: View {
	var room: RoomUI
    var body: some View {
		HStack(alignment: .top) {
			VStack(alignment: .leading, spacing: 4) {
				TextHeading200(text: room.name ?? "Work Lunch Room")
				Text("^[\(String(describing: self.room.members.count)) member](inflect: true)")
					.font(.bodyMedium)
					.foregroundStyle(.kmKaki)
				HStack(spacing: 0) {
					TextBodyMedium(text: self.room.administrator.name)
						.bold()
					TextBodyMedium(text: "is administrator")
						.padding(.leading, 5)
				}
			}

			Spacer()
			Image(room.image)
				.resizable()
				.frame(maxWidth: 120, maxHeight: 110)
		}
		.background(
			RoundedRectangle(cornerRadius: 12)
				.foregroundStyle(.clear)
				.shadow(color: .kmBlack.opacity(0.7), radius: 12, x: 2, y: 2)
		)
    }
}

#Preview {
	RoomCell(
		room: RoomUI(
			id: "12b489",
			name: "Mobile Tech Squad",
			administrator: UserUI(id: UUID(), name: "Lead")
		)
	)
}
