import Foundation
import FluentKit

struct CreateAnnotations: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AnnotationEntity.schema)
            .id()
            .field("origin_x", .double, .required)
            .field("origin_y", .double, .required)
            .field("width", .double, .required)
            .field("owner_id", .string, .required)
            .field("document_id", .uuid, .required, .references(DocumentEntity.schema, "id", onDelete: .cascade))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AnnotationEntity.schema)
            .delete()
    }
}
