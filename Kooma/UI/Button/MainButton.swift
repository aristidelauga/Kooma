
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
    var image: ImageResource?
    var symbol: String?
    var action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            if let image {
                Image(image)
                    .resizable()
                    .frame(maxWidth: 24, maxHeight: 24)
            } else {
                Image(systemName: symbol ?? "")
                    .resizable()
                    .foregroundStyle(.kmYellow)
                    .rotationEffect(.degrees(260))
                    .frame(maxWidth: 24, maxHeight: 24)
            }
        }
    }
}

#Preview {
	VStack {
        MainButton(text: "Continue", maxWidth: 112, action: {})
        MainButtonIconOnly(symbol: "phone.fill", action: {})
    }
}
