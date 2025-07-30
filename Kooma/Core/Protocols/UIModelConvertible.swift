
import Foundation

/// Any model conforming to this protocol will adopt `toUI()` method
protocol UIModelConvertible {
	associatedtype UIType
	func toUI() throws -> UIType
}
