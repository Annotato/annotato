import Foundation

public final class User: Codable, Timestampable {
    public let id: String
    public private(set) var displayName: String
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?

    public required init(
        displayName: String,
        id: String? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id ?? ""
        self.displayName = displayName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

extension User: CustomDebugStringConvertible {
    public var debugDescription: String {
        "User(id: \(id), displayName: \(displayName), " +
        "createdAt: \(String(describing: createdAt)), " +
        "updatedAt: \(String(describing: updatedAt)), " +
        "deletedAt: \(String(describing: deletedAt))"
    }
}
