import Foundation

public protocol AnnotationPart: AnyObject, Codable {
    var id: UUID { get }
    var order: Int { get set }
    var height: Double { get set }
    var annotationId: UUID { get }
    var createdAt: Date? { get set }
    var updatedAt: Date? { get set }
    var deletedAt: Date? { get set }
    var isEmpty: Bool { get }

    func remove()
}

extension AnnotationPart {
    public func setHeight(to newHeight: Double) {
        self.height = newHeight
    }

    public func setCreatedAt(to createdAt: Date) {
        self.createdAt = createdAt
    }

    public func setUpdatedAt(to updatedAt: Date) {
        self.updatedAt = updatedAt
    }

    public func setDeletedAt(to deletedAt: Date) {
        self.deletedAt = deletedAt
    }
}
