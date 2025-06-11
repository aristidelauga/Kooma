
import SwiftUI

struct KMTextfield: View {
	@Binding var text: String
	var placeholder: String?
    var body: some View {
		TextField(placeholder ?? "", text: $text)
			.foregroundStyle(.kmKaki)
			.padding(.leading, 8)
			.padding(.vertical, 12)
			.background(Color.kmBeigeSecondary)
			.textInputAutocapitalization(.words)
			.cornerRadius(12)
    }
}

#Preview {
	KMTextfield(text: .constant(""), placeholder: "username")
		.padding(.horizontal, 12)
}
