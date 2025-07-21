
import Foundation

/// Hashable protocol implemented so AppRoute is Hashable
struct RoomUI: Identifiable, Equatable, Hashable {
    var id: String?
    var hostID: String
    var code: String
    var name: String?
    var administrator: UserUI
    var address: String?
    var members: [UserUI] = []
    var regularMembersID: [String] = []
    var restaurants: [RestaurantUI] = []
    var votes: [String: [String]] = [:]
    var image: String?
    
    init(id: String? = nil, name: String? = nil, administrator: UserUI) {
        self.id = id
        self.hostID = administrator.id
        self.code = RoomUI.generateCode()
        self.name = name
        self.administrator = administrator
        self.members = [self.administrator]
        self.image = [
            "RoomOne",
            "RoomTwo",
            "RoomThree",
            "RoomFour",
            "RoomFive",
            "RoomSix",
            "RoomSeven"
        ].randomElement()!
        
    }
    
    init(
        id: String?,
        hostID: String,
        code: String,
        name: String?,
        administrator: UserUI,
        address: String?,
        members: [UserUI],
        restaurants: [RestaurantUI],
        votes: [String: [String]],
        image: String
    ) {
        self.id = id
        self.hostID = hostID
        self.code = code
        self.name = name
        self.administrator = administrator
        self.address = address
        self.members = members
        self.restaurants = restaurants
        self.votes = votes
        self.image = image
    }
    
    static func == (lhs: RoomUI, rhs: RoomUI) -> Bool {
        lhs.id == rhs.id
    }
    
    static func generateCode(length: Int = 6) -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in characters.randomElement() })
    }
}
