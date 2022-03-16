import Foundation

class AnnotationText: Codable {
    public let id: UUID?
    public let type: AnnotationType
    public private(set) var content: String
    public private(set) var height: Double
    public let annotationId: UUID

    public required init(
        type: AnnotationType, content: String, height: Double, annotationId: UUID, id: UUID? = nil
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.height = height
        self.annotationId = annotationId
    }
}
