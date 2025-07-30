
import Foundation

/// Any model conforming to this protocol will adopt `toDomain()` method
protocol DomainModelConvertible {
    associatedtype DomainType
    func toDomain() throws -> DomainType

}
