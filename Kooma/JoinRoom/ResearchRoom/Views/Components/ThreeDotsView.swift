
import SwiftUI

struct ThreeDotsView: View {
	@Binding var loading: Bool

	var body: some View {
		HStack(spacing: 5) {
			Circle()
				.fill(.kmBlack)
				.frame(width: 2, height: 2)
				.scaleEffect(loading ? 1.5 : 0.5)
				.animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: loading)
			Circle()
				.fill(.kmBlack)
				.frame(width: 2, height: 2)
				.scaleEffect(loading ? 1.5 : 0.5)
				.animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(0.2), value: loading)
			Circle()
				.fill(.kmBlack)
				.frame(width: 2, height: 2)
				.scaleEffect(loading ? 1.5 : 0.5)
				.animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(0.4), value: loading)
		}
		.onAppear() {
			self.loading = true
		}
	}
}

#Preview {
	ThreeDotsView(loading: .constant(true))
}
