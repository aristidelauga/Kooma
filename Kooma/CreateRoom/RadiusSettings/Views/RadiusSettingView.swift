
import SwiftUI
import MapKit

struct RadiusSettingView: View {
	@State private var radiusSettingViewModel: RadiusSettingViewModel
	@State private var slider: Double = 0.0
	var address: String

	init(address: String) {
		self.address = address
		_radiusSettingViewModel = State(wrappedValue: RadiusSettingViewModel(address: address))
	}

    var body: some View {
		VStack(alignment: .leading) {
			TextHeading600(text: "Location")
				.padding(.top, 12)
			AddressInfoView(address: self.radiusSettingViewModel.address)
				.padding(.top, 12)
				.padding(.bottom, 32)
			TextHeading600(text: "Radius")
				.padding(.bottom, 12)
			RadiusSliderView(slider: $slider)
			Spacer()

			MainButton(text: "Submit") {
				Task {
					await radiusSettingViewModel.searchRestaurants(within: slider)
				}
			}
			.frame(maxWidth: .infinity, alignment: .center)
        }
		.padding(.horizontal, 16)
		.navigationTitle("Lunch spots research")
		.navigationBarTitleDisplayMode(.inline)
		.background(
			Color.kmBeige
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.edgesIgnoringSafeArea(.all)
		)
		.navigationBarBackButtonHidden()
    }
}

#Preview {
    NavigationView {
		RadiusSettingView(address: "37 Rue du général Leclerc, 92130 Issy-les-Moulineaux")
    }
}
