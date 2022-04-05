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

    public func wasUpdated(after date: Date) -> Bool {
        guard let updatedAt = updatedAt else {
            return false
        }

        return updatedAt > date
    }

    public func setCreatedAt(to createdAt: Date) {
        self.createdAt = createdAt
    }

    public func setUpdatedAt(to updatedAt: Date) {
        self.updatedAt = updatedAt
    }

    public func setDeletedAt(to deletedAt: Date) {
        self.deletedAt = deletedAt
    }
}
