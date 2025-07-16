
import Foundation

struct UserUI: Identifiable, Codable, Sendable, Equatable, Hashable {
	var id: String
	var name: String
}

extension UserUI: DTOModelConvertible {
    func toDTO() throws -> UserDTO {
        UserDTO(id: self.id, name: self.name)
    }
}
