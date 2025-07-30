
import SwiftUI

struct AddressInfoView: View {
	var address: String
    var body: some View {
		HStack {
			Image(systemName: "mappin.and.ellipse")
                .foregroundStyle(.kmBlack)
				.imageScale(.large)
				.padding(10)
				.background(
					RoundedRectangle(cornerRadius: 16)
						.foregroundStyle(.kmBeigeSecondary)
				)
			VStack(alignment: .leading, spacing: 5) {
				TextBodyLarge(text: "Current Location")
				TextBodyMedium(text: address, color: .kmKaki)
					.multilineTextAlignment(.leading)
			}
		}
    }
}

#Preview {
    AddressInfoView(address: "37 rue du Général Leclerc 92130, Issy-les-Moulineaux")
}
