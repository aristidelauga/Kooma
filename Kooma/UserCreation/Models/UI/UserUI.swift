
import Foundation

struct UserUI: Identifiable, Codable, Sendable, Equatable, Hashable {
	var id: String
	var name: String
}

extension UserUI: DomainModelConvertible {
    func toDomain() throws -> UserDomain {
        UserDomain(id: self.id, name: self.name)
    }
}
