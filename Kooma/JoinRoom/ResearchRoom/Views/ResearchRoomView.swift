
import SwiftUI

struct ResearchRoomView: View {
	@State private var isLoading: Bool = false
	@Binding var navigationPath: NavigationPath
    var body: some View {
		VStack {
			Spacer()
			HStack {
				TextHeading400(text: "Looking for your room")
				ThreeDotsView(loading: $isLoading)
					.padding(.top, 10)
			}
			Spacer()

			MainButton(text: "Cancel") {
				navigationPath = NavigationPath()
			}
		}
		.navigationBarBackButtonHidden()
    }
}

#Preview {
	ResearchRoomView(navigationPath: .constant(NavigationPath()))
}

