import Foundation
import CoreGraphics

public final class Annotation: Codable {
    public let id: UUID
    public private(set) var origin: CGPoint
    public private(set) var width: Double
    public let ownerId: String
    public let documentId: UUID

    public required init(
        origin: CGPoint,
        width: Double,
        ownerId: String,
        documentId: UUID,
        id: UUID? = nil
    ) {
        self.id = id ?? UUID()
        self.origin = origin
        self.width = width
        self.ownerId = ownerId
        self.documentId = documentId
    }
}

extension Annotation: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Annotation(id: \(id), origin: \(origin), width: \(width), ownerId: \(ownerId), documentId: \(documentId)"
    }
}
