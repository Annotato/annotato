import FluentKit

extension Model {
    public static func findWithDeleted(
        _ id: Self.IDValue?,
        on database: Database
    ) -> EventLoopFuture<Self?> {
        guard let id = id else {
            return database.eventLoop.makeSucceededFuture(nil)
        }
        return Self.query(on: database)
            .filter(\._$id == id)
            .withDeleted()
            .first()
    }
}
