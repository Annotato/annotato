import Foundation

public final class Document: Codable {
    public var id: UUID
    public private(set) var name: String
    public let ownerId: String
    public let baseFileUrl: String
    public private(set) var annotations: [Annotation]
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?

    public required init(
        name: String,
        ownerId: String,
        baseFileUrl: String,
        annotations: [Annotation] = [],
        id: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id ?? UUID()
        self.name = name
        self.ownerId = ownerId
        self.baseFileUrl = baseFileUrl
        self.annotations = annotations
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

    public func addAnnotation(annotation: Annotation) {
        annotations.append(annotation)
    }

    public func removeAnnotation(annotation: Annotation) {
        annotations.removeAll(where: { $0.id == annotation.id })
    }
}

extension Document: CustomStringConvertible {
    public var description: String {
        "Document(id: \(id), name: \(name), ownerId: \(ownerId), " +
        "baseFileUrl: \(baseFileUrl), annotations: \(annotations)), " +
        "createdAt: \(String(describing: createdAt)), " +
        "updatedAt: \(String(describing: updatedAt)), " +
        "deleteAt: \(String(describing: deletedAt))"
    }
}
