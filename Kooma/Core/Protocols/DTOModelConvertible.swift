
import Foundation

@MainActor
protocol DTOModelConvertible {
	associatedtype DTOType
	associatedtype T
	func toDTO(from item: T?) throws -> DTOType
}
