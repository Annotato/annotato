import Foundation

public final class AnnotatoUser: Codable, Timestampable {
    public let id: String
    public let email: String
    public private(set) var displayName: String
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?

    public required init(
        email: String,
        displayName: String,
        id: String? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id ?? ""
        self.email = email
        self.displayName = displayName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

extension AnnotatoUser: CustomDebugStringConvertible {
    public var debugDescription: String {
        "User(id: \(id), email: \(email), displayName: \(displayName), " +
        "createdAt: \(String(describing: createdAt)), " +
        "updatedAt: \(String(describing: updatedAt)), " +
        "deletedAt: \(String(describing: deletedAt))"
    }
}
