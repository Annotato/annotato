import Foundation

public final class AnnotationText: Codable, AnnotationPart {
    public let id: UUID
    public var order: Int
    public var height: Double
    public let annotationId: UUID
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?

    public let type: AnnotationText.TextType
    public private(set) var content: String

    public var isEmpty: Bool {
        content.isEmpty
    }

    public var isDeleted: Bool {
        deletedAt != nil
    }

    @Published public private(set) var isRemoved = false

    public required init(
        type: AnnotationText.TextType,
        content: String,
        height: Double,
        order: Int,
        annotationId: UUID,
        id: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id ?? UUID()
        self.type = type
        self.content = content
        self.height = height
        self.order = order
        self.annotationId = annotationId
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
        case type
        case content
        case createdAt
        case updatedAt
        case deletedAt
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
        "height: \(height), order: \(order), annotationId: \(annotationId)), " +
        "createdAt: \(String(describing: createdAt)), " +
        "updatedAt: \(String(describing: updatedAt)), " +
        "deleteAt: \(String(describing: deletedAt))"
    }
}

extension AnnotationText {
    @objc public enum TextType: Int64, Codable {
        case plainText = 0
        case markdown = 1
    }
}
