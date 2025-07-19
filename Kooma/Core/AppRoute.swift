
import Foundation

enum AppRoute: Hashable, Equatable {
	case yourNextRoom
    case roomsList
    case roomDetails(roomID: String)
}
