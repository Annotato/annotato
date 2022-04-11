import Foundation
import AnnotatoSharedLibrary

protocol ConflictResolvable: Identifiable, Equatable, Timestampable {
    var id: UUID { get }

    func clone() -> Self
}
