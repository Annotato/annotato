import Foundation

public final class DocumentShare: Codable {
    public let id: UUID
    public private(set) var documentId: UUID
    public private(set) var recipientId: String

    public required init(
        documentId: UUID,
        recipientId: String,
        id: UUID? = nil
    ) {
        self.id = id ?? UUID()
        self.documentId = documentId
        self.recipientId = recipientId
    }
}

extension DocumentShare: CustomDebugStringConvertible {
    public var debugDescription: String {
        "DocumentShare(id: \(String(describing: id)), documentId: \(documentId), recipientId: \(recipientId)"
    }
}
