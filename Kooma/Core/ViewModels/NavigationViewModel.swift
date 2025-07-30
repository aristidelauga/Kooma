
import SwiftUI

@Observable
final class NavigationViewModel {
	var path = NavigationPath()

    /// Clean the `NavigationPath`.
    /// Used before adding one of the main screens: `RoomsListView` and `YourNextRoomView`
    private func cleanPath() {
        self.path = NavigationPath()
    }

    /// Goes from `RestaurantDetailsView` back to `RoomDetailsView`
    func goToRoomDetailsViewFromRestaurantDetails() {
        self.path.removeLast(1)
    }
    
    /// Goes from `RoomDetailsView` back to `RoomsListView`
    func goToRoomsListViewFromRoomDetails() {
        self.path.removeLast()
    }
    
    /// Goes from `OnboardingStepOneView` to `OnboardingStepTwoView`
    func goToOnboardingStepTwoView() {
        self.path.append(AppRoute.onboardingStepTwo)
    }
    
    /// Goes from `OnboardingStepTwoView` to `CreateUserView`
    func goToCreateUserView() {
        self.path.append(AppRoute.createUserView)
    }
    
    /// Goes from `CreateUserView` to `YourNextRoomView`
    /// `YourNextRoomView` will have cross-escape button if `hasRooms` is set to true.
    /// It should not be the case when the user has no rooms and sees `YourNextRoomView` for the first time
    func goToYourNextRoomViewFromUserCreation(hasRooms: Bool? = false) {
        self.path.append(AppRoute.yourNextRoom(hasRooms: hasRooms))
    }
    
    /// Goes from `SearchAddressView`, `RadiusSettingView`, `RoomsListView` or `ResearchRoomView` to `YourNextRoomView`
    func goToYourNextRoomView(hasRooms: Bool? = false) {
        self.cleanPath()
        self.path.append(AppRoute.yourNextRoom(hasRooms: hasRooms))
    }
    
    /// Goes from `RadiusSettingView`, `YourNextRoomView` or `RoomdetailsView` to `RoomsListView`
    func showRoomsListView() {
        self.cleanPath()
        self.path.append(AppRoute.roomsList)
    }
    
    /// Goes from `YourNextRoomView` to `SearchAddressView`
    func goToSearchAddressView(withRoom room: RoomUI) {
        self.path.append(AppRoute.addressSearch(room: room))
    }
    
    /// Goes from `SearchAddressView` to `RadiusSettingView`
    func goToRadiusSettingView(withRoom room: RoomUI) {
        self.path.append(AppRoute.radiusSettingView(room: room))
    }
    
    /// Goes from `YourNextRoomView` to `ResearchRoomView`
    func goToResearchRoomView(withRoomCode code: String, and hasRooms: Bool) {
        self.path.append(AppRoute.RoomSearch(code: code, hasRooms: hasRooms))
    }
    
    /// Goes from `RoomsListView` to `RoomDetailsView`
    func goToRoomDetailsView(withRoom room: RoomUI) {
        self.path.append(AppRoute.roomDetails(room: room))
    }
    
    /// Goes from `RoomDetailsView` to `RestaurantDetailView`
    func goToRestaurantDetailView(withNames names: [String], andRestaurant restaurant: RestaurantUI) {
        self.path.append(AppRoute.restaurantDetail(names: names, restaurant: restaurant))
    }

}
