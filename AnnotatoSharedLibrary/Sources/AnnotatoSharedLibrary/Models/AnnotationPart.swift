import Foundation

public protocol AnnotationPart: AnyObject, Codable, Timestampable {
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
    public var isDeleted: Bool {
        deletedAt != nil
    }

    public func setHeight(to newHeight: Double) {
        self.height = newHeight
    }
}
