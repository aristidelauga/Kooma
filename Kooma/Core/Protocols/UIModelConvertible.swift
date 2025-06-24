
import Foundation

protocol UIModelConvertible {
	associatedtype UIType
	func toUI() throws -> UIType
}
