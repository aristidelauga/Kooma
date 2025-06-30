
import Foundation

@MainActor
protocol DTORestaurantServiceConvertible {
	associatedtype DTOType
	associatedtype T
	func toDTO(from item: T?) throws -> DTOType
}
