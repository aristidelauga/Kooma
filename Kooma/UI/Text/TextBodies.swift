
import SwiftUI

struct TextBodyLarge: View {
	var text: String
	var color: Color?
    var body: some View {
        Text(text)
			.font(.bodyLarge)
			.foregroundStyle(color ?? Color.KMBlack)
    }
}

struct TextBodyMedium: View {
	var text: String
	var color: Color?
	var body: some View {
		Text(text)
			.font(.bodyMedium)
			.foregroundStyle(color ?? Color.KMBlack)
	}
}

#Preview {
	TextBodyLarge(text: "Quickly and easily where to have lunch", color: .black)
	TextBodyMedium(text: "Quickly and easily where to have lunch", color: .black)
}
