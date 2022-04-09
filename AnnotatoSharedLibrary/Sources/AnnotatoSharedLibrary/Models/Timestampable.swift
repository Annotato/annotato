import Foundation

public protocol Timestampable: AnyObject {
    var createdAt: Date? { get set }
    var updatedAt: Date? { get set }
    var deletedAt: Date? { get set }

    func setCreatedAt(to createdAt: Date)
    func setUpdatedAt(to updatedAt: Date)
    func setDeletedAt(to deletedAt: Date)
}

extension Timestampable {
    public var isDeleted: Bool {
        deletedAt != nil
    }

    public func wasCreated(after date: Date) -> Bool {
        guard let createdAt = createdAt else {
            return false
        }

        return createdAt > date
    }

    public func wasUpdated(after date: Date) -> Bool {
        guard let updatedAt = updatedAt else {
            return false
        }

        return updatedAt > date
    }

    public func setCreatedAt(to createdAt: Date = Date()) {
        self.createdAt = createdAt

        setUpdatedAt(to: createdAt)
    }

    public func setUpdatedAt(to updatedAt: Date = Date()) {
        self.updatedAt = updatedAt
    }

    public func setDeletedAt(to deletedAt: Date = Date()) {
        self.deletedAt = deletedAt

        setUpdatedAt(to: deletedAt)
    }
}
