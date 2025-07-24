
import SwiftUI

struct KMTextfield: View {
	@Binding var text: String
	var placeholder: String?
    var joiningTextfield: Bool?
    var body: some View {
		TextField(placeholder ?? "", text: $text)
			.foregroundStyle(.kmKaki)
			.padding(.leading, 8)
			.padding(.vertical, 12)
			.background(Color.kmBeigeSecondary)
			.textInputAutocapitalization(joiningTextfield ?? false ? .characters :.words)
			.cornerRadius(12)
    }
}

#Preview {
	KMTextfield(text: .constant(""), placeholder: "username")
		.padding(.horizontal, 12)
}
