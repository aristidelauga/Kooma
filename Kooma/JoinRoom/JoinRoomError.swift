
import Foundation

enum JoinRoomError: Error {
    case alreadyJoined
    case unableToFindRoom
    case noInternetConnection
    
    var title: String {
        switch self {
        case .alreadyJoined:
            "You already joined this room"
        case .unableToFindRoom:
            "Unable to find room matching your code"
        case .noInternetConnection:
            "No internet connection"
        }
    }
    
    var message: String {
        switch self {
        case .alreadyJoined:
            "Feel free to retry with a different code"
        case .unableToFindRoom:
            "Please try again later"
        case .noInternetConnection:
            "Make sure you are connected to internet"
        }
    }
    
    var actionTitle: String { "OK" }
}
