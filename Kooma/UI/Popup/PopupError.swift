
import SwiftUI

struct PopupError: View {
    var error: JoinRoomError
    var buttonAction: () -> Void
    var body: some View {
        VStack(spacing: 12) {
            TextHeading200(text: error.title)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
            TextBodyMedium(text: error.message)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
            MainButton(text: error.actionTitle, maxWidth: 78, maxHeight: 34) {
                buttonAction()
            }
        }
        .frame(maxWidth: 250)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(.kmBeigeSecondary))
        )
    }
}

#Preview {
    VStack {
        PopupError(error: JoinRoomError.unableToFindRoom, buttonAction: {})
        PopupError(error: JoinRoomError.alreadyJoined, buttonAction: {})
        PopupError(error: JoinRoomError.noInternetConnection, buttonAction: {})
    }
}
