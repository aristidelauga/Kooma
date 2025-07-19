
import Foundation

protocol DomainModelConvertible {
    associatedtype DomainType
    func toDomain() throws -> DomainType

}
