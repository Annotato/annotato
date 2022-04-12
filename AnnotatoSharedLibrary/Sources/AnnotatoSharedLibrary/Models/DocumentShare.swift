import Foundation

public final class DocumentShare: Codable, Timestampable {
    public let id: UUID
    public private(set) var documentId: UUID
    public private(set) var recipientId: String
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?

    public required init(
        documentId: UUID,
        recipientId: String,
        id: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id ?? UUID()
        self.documentId = documentId
        self.recipientId = recipientId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

extension DocumentShare: CustomDebugStringConvertible {
    public var debugDescription: String {
        "DocumentShare(id: \(String(describing: id)), documentId: \(documentId), recipientId: \(recipientId), " +
        "createdAt: \(String(describing: createdAt)), " +
        "updatedAt: \(String(describing: updatedAt)), " +
        "deletedAt: \(String(describing: deletedAt))"
    }
}
