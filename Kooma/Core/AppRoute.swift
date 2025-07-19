
import Foundation

enum AppRoute: Hashable, Equatable {
    case yourNextRoom(hasRooms: Bool? = false)
    case roomsList
    case roomDetails(roomID: String)
    case addressSearch(room: RoomUI)
    case radiusSettingView(room: RoomUI)
    case RoomSearch(code: String)
}
