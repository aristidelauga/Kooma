
import Foundation

@Observable
final class RoomsListViewModel {
	var rooms: [RoomUI] = []
    

    private func saveRooms() {
        
    }
    
	func addNewRoom(_ room: RoomUI) {
		self.rooms.append(room)
	}
    
}
