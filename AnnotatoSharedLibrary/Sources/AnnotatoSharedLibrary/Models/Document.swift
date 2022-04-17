import Foundation

public final class Document: Codable, Timestampable {
    public var id: UUID
    public private(set) var name: String
    public var ownerId: String
    public private(set) var annotations: [Annotation]
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?

    public required init(
        name: String,
        ownerId: String,
        annotations: [Annotation] = [],
        id: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id ?? UUID()
        self.name = name
        self.ownerId = ownerId
        self.annotations = annotations
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

    public func addAnnotation(annotation: Annotation) {
        annotations.append(annotation)
    }

    public func updateAnnotation(updatedAnnotation: Annotation) {
        guard let idx = annotations.firstIndex(where: { $0.id == updatedAnnotation.id }) else {
            return
        }

        annotations[idx] = updatedAnnotation
    }

    public func receiveRestoreDeletedAnnotation(annotation: Annotation) {
        annotations.removeAll(where: { $0.id == annotation.id })
        annotations.append(annotation)
    }

    public func contains(annotation: Annotation) -> Bool {
        annotations.contains(where: { $0.id == annotation.id })
    }

    public func setAnnotations(annotations: [Annotation]) {
        self.annotations = annotations
    }
}

// MARK: Timestamps
extension Document {
    public func setCreatedAt(to createdAt: Date = Date()) {
        self.createdAt = createdAt
        for annotation in annotations {
            annotation.setCreatedAt(to: createdAt)
        }

        setUpdatedAt(to: createdAt)
    }

    public func setUpdatedAt(to updatedAt: Date = Date()) {
        self.updatedAt = updatedAt
        for annotation in annotations {
            annotation.setUpdatedAt(to: updatedAt)
        }
    }

    public func setDeletedAt(to deletedAt: Date = Date()) {
        self.deletedAt = deletedAt
        for annotation in annotations {
            annotation.setDeletedAt(to: deletedAt)
        }

        setUpdatedAt(to: deletedAt)
    }
}

extension Document: CustomStringConvertible {
    public var description: String {
        "Document(id: \(id), name: \(name), ownerId: \(ownerId), " +
        "annotations: \(annotations)), " +
        "createdAt: \(String(describing: createdAt)), " +
        "updatedAt: \(String(describing: updatedAt)), " +
        "deletedAt: \(String(describing: deletedAt))"
    }
}

extension Document: Equatable {
    public static func == (lhs: Document, rhs: Document) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.ownerId == rhs.ownerId
    }
}

extension Document: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(ownerId)
    }
}
