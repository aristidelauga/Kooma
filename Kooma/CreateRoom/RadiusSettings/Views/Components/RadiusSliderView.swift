
import SwiftUI

struct RadiusSliderView: View {
	@Binding var slider: Double
    var body: some View {
		HStack {
			TextBodyMedium(text: "How far are you willing to go?")
			Spacer()
			TextBodyMedium(text: "\(Int(slider)) km")
		}
		Slider(value: $slider, in: 0...10)
			.tint(.kmYellow)
    }
}

#Preview {
	RadiusSliderView(slider: .constant(8.0))
}
