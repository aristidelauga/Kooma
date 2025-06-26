
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
                .cornerRadius(12, corners: [.topLeft, .topRight])
            

			VStack(alignment: .leading, spacing: 6){
				TextHeading600(text: room.name ?? "Work Lunch Room")
                
                Text(.init("**\(self.room.administrator.name)** is the administrator"))
                    .font(.bodyLarge)
                    .foregroundStyle(.kmBlack)
                    .fixedSize(horizontal: false, vertical: true)
                
				Text("^[\(String(describing: self.room.members.count)) member](inflect: true)")
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
                .shadow(color: .kmBlack.opacity(0.2), radius: 7, x: 12, y: 5)
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
                    administrator: UserUI(id: UUID(), name: "KawabungaDelToro")
                )
            )
            .padding(.trailing)
//            RoomCell(
//                room: RoomUI(
//                    id: "12b489",
//                    name: "Mobile Tech Squad",
//                    administrator: UserUI(id: UUID(), name: "KawabungaElMatador")
//                )
//            )
//            .padding(.trailing)
//            RoomCell(
//                room: RoomUI(
//                    id: "12b489",
//                    name: "Mobile Tech Squad",
//                    administrator: UserUI(id: UUID(), name: "Lead")
//                )
//            )
//            .padding(.trailing)
        }
        .padding(.vertical)
    }
}
