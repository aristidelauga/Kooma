
import SwiftUI

@Observable
final class NavigationViewModel {
	var path = NavigationPath()

	func showRoomsListView() {
		self.path = NavigationPath()
	}

	func goToYourNextRoomView() {
		self.path.append(AppRoute.yourNextRoom)
	}
}
