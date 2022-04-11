import Foundation
import FluentKit

struct CreateDocuments: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(DocumentEntity.schema)
            .id()
            .field("name", .string, .required)
            .field("owner_id", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(DocumentEntity.schema)
            .delete()
    }
}
