
import Foundation
@preconcurrency import FirebaseFirestore

struct RoomDomain: Identifiable, Sendable, Codable {
    @DocumentID var id: String?
    var hostID: String {
        administrator.id
    }
    var code: String
    var name: String?
    var administrator: UserDomain
    var address: String
    var members: [UserDomain] = []
    var regularMembersID: [String] = []
    var restaurants: [RestaurantDomain] = []
    var votes: [String: [String]] = [:]
    var image: String
}

extension RoomDomain {
    func toUI() -> RoomUI {
        RoomUI(
            id: self.id,
            hostID: self.hostID,
            code: self.code,
            name: self.name,
            administrator: self.administrator.toUI(),
            address: self.address,
            members: self.members.map { $0.toUI() },
            restaurants: self.restaurants.map { $0.toUI() }
        )
    }
}
