
import Foundation

/// Any model conforming to this protocol will adopt `toDTO()` method
@MainActor
protocol DTORestaurantServiceConvertible {
	associatedtype DTOType
	associatedtype T
	func toDTO(from item: T?) throws -> DTOType
}
