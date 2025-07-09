
import Foundation
@preconcurrency import FirebaseFirestore

struct UserDTO: Identifiable, Codable, Sendable {
	@DocumentID var id: String?
	var name: String
}

extension UserDTO: UIModelConvertible {
	func toUI() throws -> UserUI {
        guard let id = self.id else {
            return .init(id: "", name: self.name)
        }
		return UserUI(id: id, name: self.name)
	}
}
