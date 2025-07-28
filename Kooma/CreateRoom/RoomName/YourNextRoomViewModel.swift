
import Foundation
import FirebaseAnalytics

@MainActor
@Observable final class YourNextRoomViewModel {
	var room: RoomUI?
	var name: String = ""
	var user: UserUI
	
	init(user: UserUI) {
		self.user = user
	}

    /// Create a room with a name and the administrator only.
    /// The ID has to be nil as it will be given a value via Firestore
	func createRoomWithName(with owner: UserUI)  {
        guard !self.name.isEmpty else {
            return
        }
		self.room = RoomUI(name: self.name, administrator: owner)
        ActionEvent.sendAnalytics(event: .createNewRoom(userID: owner.id))
	}
    
    /// Analytics triggered when the user taps on "Join Room"
    func sendAnalyticsForJoiningRoom() {
        ActionEvent.sendAnalytics(event: .joinRoom(userID: self.user.id))
    }
}
