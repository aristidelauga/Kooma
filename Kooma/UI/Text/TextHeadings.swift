
import SwiftUI

struct TextHeading800: View {
	var text: String
	var color: Color?
    var body: some View {
		VStack {
			Text(text)
				.font(.heading800)
				.foregroundStyle(color ?? .KMBlack)
		}
    }
}

struct TextHeading600: View {
	var text: String
	var color: Color?
	var body: some View {
		VStack {
			Text(text)
				.font(.heading600)
				.foregroundStyle(color ?? .KMBlack)
		}
	}
}

struct TextHeading400: View {
	var text: String
	var color: Color?
	var body: some View {
		VStack {
			Text(text)
				.font(.heading400)
				.foregroundColor(color ?? .KMBlack)
		}
	}
}

struct TextHeading200: View {
	var text: String
	var color: Color?
	var body: some View {
		VStack {
			Text(text)
				.font(.heading200)
				.foregroundStyle(color ?? .KMBlack)
		}
	}
}


#Preview {
	TextHeading800(text: "Lunch decisions made easy", color: .black)
}
