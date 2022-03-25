import Foundation
import FluentKit

struct CreateDocumentShares: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(DocumentShareEntity.schema)
            .id()
            .field("document_id", .uuid, .required, .references(DocumentEntity.schema, "id", onDelete: .cascade))
            .field("recipient_id", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .unique(on: "document_id", "recipient_id")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(DocumentShareEntity.schema)
            .delete()
    }
}
