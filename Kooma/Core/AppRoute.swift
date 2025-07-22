
import Foundation

enum AppRoute: Hashable, Equatable {
    case onboardingStepTwo
    case createUserView
    case yourNextRoom(hasRooms: Bool? = false)
    case roomsList
    case roomDetails(room: RoomUI)
    case addressSearch(room: RoomUI)
    case radiusSettingView(room: RoomUI)
    case RoomSearch(code: String)
    case restaurantDetail(names: [String], restaurant: RestaurantUI)
}
