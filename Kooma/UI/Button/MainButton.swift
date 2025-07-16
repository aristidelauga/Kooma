
import SwiftUI

struct MainButton: View {
	var text: String
	var maxWidth: CGFloat?
	var maxHeight: CGFloat?
	var action: () -> Void
    var body: some View {
		Button {
			action()
		} label: {
			TextHeading200(text: text)
		}
		.padding(.vertical, 20)
		.padding(.horizontal, 12)
		.frame(maxWidth: maxWidth ?? 112, maxHeight: maxHeight ?? 48)
		.background(
			RoundedRectangle(cornerRadius: 48)
				.foregroundStyle(.kmYellow)
		)
    }
}

struct MainButtonIconOnly: View {
    @Binding var image: ImageResource
    var action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            Image(image)
                .resizable()
                .frame(maxWidth: 24, maxHeight: 24)
        }
    }
}

#Preview {
	VStack {
        MainButton(text: "Continue", maxWidth: 112, action: {})
        MainButtonIconOnly(image: .constant(.thumbFill), action: {})
    }
}
