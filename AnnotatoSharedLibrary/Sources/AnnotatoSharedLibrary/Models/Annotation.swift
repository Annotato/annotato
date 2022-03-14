import Foundation
import CoreGraphics

public class Annotation: Codable {
    public var id: UUID?
    public let ownerId: UUID
    public private(set) var document: Document
    public var center: CGPoint
    public var width: Double
    public var parts: [AnnotationPart]

    public required init(ownerId: UUID, document: Document, center: CGPoint,
                         width: Double, parts: [AnnotationPart], id: UUID? = nil) {
        self.id = id
        self.ownerId = ownerId
        self.document = document
        self.center = center
        self.width = width
        self.parts = parts
    }
}
