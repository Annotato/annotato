import FluentKit

extension ChildrenProperty {
    func loadWithDeleted(on database: Database) -> EventLoopFuture<Void> {
        self.query(on: database).withDeleted().all().map {
            self.value = $0
        }
    }
}
