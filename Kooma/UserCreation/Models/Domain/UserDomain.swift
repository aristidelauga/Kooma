
import Foundation
@preconcurrency import FirebaseFirestore

struct UserDomain: Identifiable, Sendable, Codable {
    var id: String
    var name: String
}

extension UserDomain {
    func toUI() -> UserUI {
        UserUI(id: self.id, name: self.name)
    }
}
