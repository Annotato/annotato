import Foundation

public final class AnnotationText: Codable, AnnotationPart {
    public let id: UUID
    public private(set) var order: Int
    public var height: Double
    public let annotationId: UUID

    public let type: AnnotationText.TextType
    public private(set) var content: String

    public var isEmpty: Bool {
        content.isEmpty
    }

    @Published public private(set) var isRemoved = false

    public required init(
        type: AnnotationText.TextType,
        content: String,
        height: Double,
        order: Int,
        annotationId: UUID,
        id: UUID? = nil
    ) {
        self.id = id ?? UUID()
        self.type = type
        self.content = content
        self.height = height
        self.order = order
        self.annotationId = annotationId
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case order
        case height
        case annotationId
        case type
        case content
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        order = try container.decode(Int.self, forKey: .order)
        height = try container.decode(Double.self, forKey: .height)
        annotationId = try container.decode(UUID.self, forKey: .annotationId)
        type = try container.decode(AnnotationText.TextType.self, forKey: .type)
        content = try container.decode(String.self, forKey: .content)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(order, forKey: .order)
        try container.encode(height, forKey: .height)
        try container.encode(annotationId, forKey: .annotationId)
        try container.encode(type, forKey: .type)
        try container.encode(content, forKey: .content)
    }

    public func setContent(to newContent: String) {
        self.content = newContent
    }

    public func remove() {
        isRemoved = true
    }
}

extension AnnotationText: CustomDebugStringConvertible {
    public var debugDescription: String {
        "AnnotationText(id: \(id), type: \(type), content: \(content), " +
        "height: \(height), order: \(order), annotationId: \(annotationId))"
    }
}

extension AnnotationText {
    public enum TextType: Int, Codable {
        case plainText
        case markdown
    }
}
