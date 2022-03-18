import Foundation
import CoreGraphics

public final class Annotation: Codable {
    public let id: UUID?
    public private(set) var origin: CGPoint
    public private(set) var width: Double
    public let ownerId: String
    public let documentId: UUID

    public required init(origin: CGPoint, width: Double, ownerId: String, documentId: UUID, id: UUID? = nil) {
        self.id = id
        self.origin = origin
        self.width = width
        self.ownerId = ownerId
        self.documentId = documentId
    }
}
