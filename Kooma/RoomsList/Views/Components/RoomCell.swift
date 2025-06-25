
import SwiftUI

struct RoomCell: View {
	var room: RoomUI
    var body: some View {
//		HStack(alignment: .top) {
//			VStack(alignment: .leading, spacing: 4) {
//				TextHeading200(text: room.name ?? "Work Lunch Room")
//				Text("^[\(String(describing: self.room.members.count)) member](inflect: true)")
//					.font(.bodyMedium)
//					.foregroundStyle(.kmKaki)
//				HStack(spacing: 0) {
//					TextBodyMedium(text: self.room.administrator.name)
//						.bold()
//					TextBodyMedium(text: "is administrator")
//						.padding(.leading, 5)
//				}
//			}
//			.padding(.top, 8)
//
//			Spacer()
//			Image(room.image)
//				.resizable()
//				.frame(maxWidth: 120, maxHeight: 110)
//		}
//		.padding(.leading, 8)
//		.background(
//			RoundedRectangle(cornerRadius: 15)
//				.foregroundStyle(.white)
//				.shadow(color: .kmBlack.opacity(0.3), radius: 7, x: 12, y: 2)
//		)
		VStack(alignment: .leading) {
			Image(room.image)
				.resizable()
				.frame(maxWidth: .infinity, maxHeight: 140)

			VStack(alignment: .leading, spacing: 6){
				TextHeading600(text: room.name ?? "Work Lunch Room")

				HStack(spacing: 0) {
					TextBodyMedium(text: self.room.administrator.name)
						.bold()
					TextBodyMedium(text: "is the administrator")
						.padding(.leading, 5)
				}

				Text("^[\(String(describing: self.room.members.count)) member](inflect: true)")
					.font(.heading200)
					.foregroundStyle(.kmKaki)

			}
		}
		.frame(maxWidth: 230)
		.background(
			RoundedRectangle(cornerRadius: 12)
				.foregroundStyle(.clear)
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
