
import Foundation

@Observable
final class RoomsListViewModel {
	var rooms: [RoomUI] = []

	func addNewRoom(_ room: RoomUI) {
		self.rooms.append(room)
	}
}
