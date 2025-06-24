
import Foundation

struct UserDTO: Identifiable, Codable, Sendable {
	var id: UUID
	var name: String
}

extension UserDTO: UIModelConvertible {
	func toUI() throws -> UserUI {
		UserUI(id: self.id, name: self.name)
	}
}
