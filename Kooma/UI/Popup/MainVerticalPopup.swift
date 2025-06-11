
import SwiftUI

struct MainVerticalPopup: View {
	@Binding var navigationPath: NavigationPath
    var body: some View {
		VStack(alignment: .center) {
			TextHeading200(text: "No room has been found")
			TextBodyMedium(text: "Retry again or create a room of your own")
				.padding(.vertical, 11)
			MainButton(text: "Exit", maxHeight: 45) {
				navigationPath = NavigationPath()
			}
		}
		.padding(21)
		.background(
			RoundedRectangle(cornerRadius: 24)
				.fill(Color.kmBeige)
		)
    }
}

#Preview {
	MainVerticalPopup(navigationPath: .constant(NavigationPath()))
}
