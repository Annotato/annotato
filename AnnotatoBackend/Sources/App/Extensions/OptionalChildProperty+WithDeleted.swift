import FluentKit

extension OptionalChildProperty {
    func loadWithDeleted(on database: Database) -> EventLoopFuture<Void> {
        self.query(on: database).withDeleted().first().map {
            self.value = $0
        }
    }
}
