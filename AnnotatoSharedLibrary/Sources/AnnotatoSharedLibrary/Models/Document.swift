import Foundation

public final class Document: Codable {
    public var id: UUID
    public private(set) var name: String
    public let ownerId: String
    public let baseFileUrl: String

    public required init(id: UUID = UUID(), name: String, ownerId: String, baseFileUrl: String) {
        self.id = id
        self.name = name
        self.ownerId = ownerId
        self.baseFileUrl = baseFileUrl
    }
}

extension Document: CustomStringConvertible {
    public var description: String {
        "Document(id: \(id), name: \(name), ownerId: \(ownerId), baseFileUrl: \(baseFileUrl))"
    }
}
