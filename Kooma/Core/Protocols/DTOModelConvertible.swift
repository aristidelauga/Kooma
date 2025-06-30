
import Foundation

protocol DTOModelConvertible {
    associatedtype DTOType
    func toDTO() throws -> DTOType

}
