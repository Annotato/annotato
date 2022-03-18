import Foundation

public final class Document: Codable {
    public var id: UUID
    public private(set) var name: String
    public let ownerId: String
    public let baseFileUrl: String
    public private(set) var annotations: [Annotation]

    public required init(id: UUID? = nil, name: String, ownerId: String, baseFileUrl: String, annotations: [Annotation] = []) {
        self.id = id ?? UUID()
        self.name = name
        self.ownerId = ownerId
        self.baseFileUrl = baseFileUrl
        self.annotations = annotations
    }

    public func addAnnotation(annotation: Annotation) {
        annotations.append(annotation)
    }
}

extension Document: CustomStringConvertible {
    public var description: String {
        "Document(id: \(id), name: \(name), ownerId: \(ownerId), baseFileUrl: \(baseFileUrl), annotations: \(annotations)"
    }
}
