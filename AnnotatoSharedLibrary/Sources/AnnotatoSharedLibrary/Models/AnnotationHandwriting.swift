import Foundation
import PencilKit

public final class AnnotationHandwriting: Codable, AnnotationPart {
    public var id: UUID
    public var order: Int
    public var height: Double
    public var annotationId: UUID

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
        id: UUID? = nil
    ) {
        self.id = id ?? UUID()
        self.order = order
        self.height = height
        self.annotationId = annotationId
        self.handwriting = handwriting
    }

    // Define manually as we do not want all properties to be encoded/decoded
    private enum CodingKeys: String, CodingKey {
        case id
        case order
        case height
        case annotationId
        case handwriting
    }

    public func setHandwriting(to newHandwriting: Data) {
        self.handwriting = newHandwriting
    }

    public func remove() {
        isRemoved = true
    }

}
