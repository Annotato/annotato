import Foundation

public class AnnotationPart: Codable {
    public var id: UUID?
    public var height: Double
    public var content: String
    public let annotationType: String // TODO: Change this to enum

    public required init(id: UUID?, height: Double, content: String, annotationType: String) {
        self.id = id
        self.height = height
        self.content = content
        self.annotationType = annotationType
    }
}
