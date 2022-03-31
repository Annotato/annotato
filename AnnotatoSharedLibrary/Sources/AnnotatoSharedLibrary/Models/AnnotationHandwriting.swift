import Foundation
import PencilKit

public final class AnnotationHandwriting: Codable, AnnotationPart {
    public var id: UUID
    public var order: Int
    public var height: Double
    public var annotationId: UUID
    public let createdAt: Date?
    public let updatedAt: Date?
    public let deletedAt: Date?

    public private(set) var handwriting: Data

    public var isEmpty: Bool {
        (try? PKDrawing(data: handwriting).bounds.isEmpty) ?? false
    }

    @Published public private(set) var isRemoved = false

    public required init(
        order: Int,
        height: Double,
        annotationId: UUID,
        handwriting: Data,
        id: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id ?? UUID()
        self.order = order
        self.height = height
        self.annotationId = annotationId
        self.handwriting = handwriting
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

    // Define manually as we do not want all properties to be encoded/decoded
    private enum CodingKeys: String, CodingKey {
        case id
        case order
        case height
        case annotationId
        case handwriting
        case createdAt
        case updatedAt
        case deletedAt
    }

    public func setHandwriting(to newHandwriting: Data) {
        self.handwriting = newHandwriting
    }

    public func remove() {
        isRemoved = true
    }
}

extension AnnotationHandwriting: CustomDebugStringConvertible {
    public var debugDescription: String {
        "AnnotationHandwriting(id: \(id), height: \(height), " +
        "order: \(order), annotationId: \(annotationId)), " +
        "createdAt: \(String(describing: createdAt)), " +
        "updatedAt: \(String(describing: updatedAt)), " +
        "deleteAt: \(String(describing: deletedAt))"
    }
}
