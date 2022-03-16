import Foundation
import CoreGraphics

public class Annotation: Codable {
    public let id: UUID?
    public private(set) var origin: CGPoint
    public private(set) var width: Double
    public let ownerId: UUID

    public required init(origin: CGPoint, width: Double, ownerId: UUID, id: UUID? = nil) {
        self.id = id
        self.origin = origin
        self.width = width
        self.ownerId = ownerId
    }
}
