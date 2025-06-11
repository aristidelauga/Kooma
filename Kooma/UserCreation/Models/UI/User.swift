
import Foundation

struct User: Identifiable, Codable, Sendable {
	var id: UUID
	var name: String
}

