import Foundation

@available(iOS 13.0, *)
public final class Document: Codable {
    public var id: UUID
    public private(set) var name: String
    public let ownerId: String
    public let baseFileUrl: String
    public private(set) var annotations: [Annotation]

    public required init(
        name: String,
        ownerId: String,
        baseFileUrl: String,
        annotations: [Annotation] = [],
        id: UUID? = nil
    ) {
        self.id = id ?? UUID()
        self.name = name
        self.ownerId = ownerId
        self.baseFileUrl = baseFileUrl
        self.annotations = annotations
    }
}

@available(iOS 13.0, *)
extension Document: CustomStringConvertible {
    public var description: String {
        "Document(id: \(id), name: \(name), ownerId: \(ownerId), " +
        "baseFileUrl: \(baseFileUrl), annotations: \(annotations))"
    }
}
