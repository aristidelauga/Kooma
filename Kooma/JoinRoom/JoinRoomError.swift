
import Foundation

enum JoinRoomError: Error {
    case alreadyJoined
    case administrator
    case unableToFindRoom
    case noInternetConnection
    
    var title: String {
        switch self {
        case .alreadyJoined:
            "You already joined this room"
        case .administrator:
            "You are the administrator of this room"
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
        case .administrator:
            "You can't join this room as you are the administrator"
        case .unableToFindRoom:
            "Please try again later"
        case .noInternetConnection:
            "Make sure you are connected to internet"
        }
    }
    
    var actionTitle: String { "OK" }
}
