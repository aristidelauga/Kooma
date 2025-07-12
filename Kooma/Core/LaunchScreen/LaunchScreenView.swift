

import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        Image(.launchScreen)
            .resizable()
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, maxHeight: 70)
            .padding(.top, 20)
    }
}

#Preview {
    LaunchScreenView()
}
