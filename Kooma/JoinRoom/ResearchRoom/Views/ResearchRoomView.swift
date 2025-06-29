
import SwiftUI

struct ResearchRoomView: View {
	@State private var isLoading: Bool = false
//	@Binding var navigationPath: NavigationPath
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
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
				self.presentationMode.wrappedValue.dismiss()
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(
			Color.kmBeige
				.edgesIgnoringSafeArea(.all)
		)
		.navigationBarBackButtonHidden()
    }
}

#Preview {
	ResearchRoomView()
}


