
import SwiftUI

@Observable
final class NavigationViewModel {
	var path = NavigationPath()
    var showRoomsList = false

    func cleanPath() {
        self.path = NavigationPath()
    }
    
	func showRoomsListView() {
        self.cleanPath()
        self.path.append(AppRoute.roomsList)
    }

    func goToYourNextRoomView(hasRooms: Bool? = false) {
        self.cleanPath()
		self.path.append(AppRoute.yourNextRoom(hasRooms: hasRooms))
	}
    
    func goToSearchAddressView(withRoom room: RoomUI) {
        self.path.append(AppRoute.addressSearch(room: room))
    }
    
    func goToRadiusSettingView(withRoom room: RoomUI) {
        self.path.append(AppRoute.radiusSettingView(room: room))
    }
    
    func goToResearchRoomView(withRoomCode code: String) {
        self.path.append(AppRoute.RoomSearch(code: code))
    }

}
