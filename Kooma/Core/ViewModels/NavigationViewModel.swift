
import SwiftUI

@Observable
final class NavigationViewModel {
	var path = NavigationPath()
    var comingFromRestaurantView = false
//    var showRoomsList = false

    private func cleanPath() {
        self.path = NavigationPath()
    }

    
    func goToRoomDetailsViewFromRestaurantDetails() {
        self.path.removeLast(1)
    }
    
    func goToRoomsListViewFromRoomDetails() {
        self.path.removeLast()
    }
    
    func goToOnboardingStepTwoView() {
        self.path.append(AppRoute.onboardingStepTwo)
    }
    
    func goToCreateUserView() {
        self.path.append(AppRoute.createUserView)
    }
    
	func showRoomsListView() {
        self.cleanPath()
        self.path.append(AppRoute.roomsList)
    }
    
    func goToYourNextRoomViewFromUserCreation(hasRooms: Bool? = false) {
        self.path.append(AppRoute.yourNextRoom(hasRooms: hasRooms))
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
    
    
    func goToRoomDetailsView(withRoom room: RoomUI) {
        self.path.append(AppRoute.roomDetails(room: room))
    }
    
    func goToRestaurantDetailView(withNames names: [String], andRestaurant restaurant: RestaurantUI) {
        self.path.append(AppRoute.restaurantDetail(names: names, restaurant: restaurant))
    }

}
