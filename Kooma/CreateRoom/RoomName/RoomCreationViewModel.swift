
import Foundation

@MainActor
@Observable final class RoomCreationViewModel {
	var room: RoomUI?
	var name: String = ""
	var user: UserUI
	
	init(user: UserUI) {
		self.user = user
	}

	func createRoomWithName(with owner: UserUI)  {
		self.room = RoomUI(name: self.name, administrator: owner)
	}
}
