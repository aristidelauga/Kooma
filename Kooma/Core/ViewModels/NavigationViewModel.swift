
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

	func goToYourNextRoomView() {
        self.cleanPath()
		self.path.append(AppRoute.yourNextRoom)
	}
    

}
