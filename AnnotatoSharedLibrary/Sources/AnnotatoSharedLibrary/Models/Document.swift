import Foundation

public final class Document: Codable {
    public var id: UUID
    public private(set) var name: String
    public let ownerId: String
    public let baseFileUrl: String
    public private(set) var annotations: [Annotation]
    public private(set) var createdAt: Date?
    public private(set) var updatedAt: Date?
    public private(set) var deletedAt: Date?

    public var isDeleted: Bool {
        deletedAt != nil
    }

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

// MARK: Timestamps
extension Document {
    public func setCreatedAt(to createdAt: Date) {
        self.createdAt = createdAt
        for annotation in annotations {
            annotation.setCreatedAt(to: createdAt)
        }
    }

    public func setUpdatedAt(to updatedAt: Date) {
        self.updatedAt = updatedAt
        for annotation in annotations {
            annotation.setUpdatedAt(to: updatedAt)
        }
    }

    public func setDeletedAt(to deletedAt: Date) {
        self.deletedAt = deletedAt
        for annotation in annotations {
            annotation.setDeletedAt(to: deletedAt)
        }
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

extension Document: Equatable {
    public static func == (lhs: Document, rhs: Document) -> Bool {
        lhs.id == rhs.id
    }
}

extension Document: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
