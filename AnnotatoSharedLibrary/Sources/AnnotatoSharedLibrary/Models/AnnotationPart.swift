import Foundation

public class AnnotationPart: Codable {
    public var id: UUID?
    public var height: Double
    public var content: String
    public let annotationType: AnnotationType

    public required init(id: UUID?, height: Double, content: String, annotationType: AnnotationType) {
        self.id = id
        self.height = height
        self.content = content
        self.annotationType = annotationType
    }
}
