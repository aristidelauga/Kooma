
import Foundation
import FirebaseAnalytics

@MainActor
enum ActionEvent: Equatable {
    case createNewRoom(userID: String)
    case createdNewRoomSuccessfully
    case joinRoom(userID: String)
    case createNewUser(userID: String)
    case callRestaurant
    case openWebView
    case openAppleMaps

    
    var name: String {
        switch self {
        case .createNewRoom:
            "create_new_room_button_tapped"
        case .createdNewRoomSuccessfully:
            "created_new_room_successfully"
        case .joinRoom:
            "join_room_button_tapped"
        case .createNewUser:
            "create_new_user_button_tapped"
        case .callRestaurant:
            "call_restaurant_button_tapped"
        case .openWebView:
            "web_view_button_tapped"
        case .openAppleMaps:
            "apple_maps_button_tapped"
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .createNewRoom(let userID):
            ["user_id": userID]
        case .joinRoom(let userID):
            ["user_id": userID]
        case .createNewUser(let userID):
            ["user_id": userID]
        default:
            [:]
        }
    }
    
    var printStatement: String {
        switch self {
        case .createNewRoom(let userID):
            return "User \(userID) tapped the button to create a new room."
        case .createdNewRoomSuccessfully:
            return "User successfully created a new room."
        case .joinRoom(let userID):
            return "User \(userID) attempted to join a new room."
        case .createNewUser(userID: let userID):
            return "User \(userID) tapped the button to create a new user."
        case .callRestaurant:
            return "User tapped the button to call the restaurant."
        case .openWebView:
            return "User opened the web view."
        case .openAppleMaps:
            return "User opened Apple Maps."
        }
    }
    
    static func sendAnalytics(event: ActionEvent) {
        Analytics.logEvent(event.name, parameters: event.parameters)
        print(event.printStatement)
    }
}
