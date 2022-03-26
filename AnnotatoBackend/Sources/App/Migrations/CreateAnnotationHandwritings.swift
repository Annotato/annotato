import Foundation
import FluentKit

struct CreateAnnotationHandwritings: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AnnotationHandwritingEntity.schema)
            .id()
            .field("handwriting", .data, .required)
            .field("height", .double, .required)
            .field("order", .int, .required)
            .field("annotation_id", .uuid, .required, .references(AnnotationEntity.schema, "id", onDelete: .cascade))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AnnotationHandwritingEntity.schema)
            .delete()
    }
}
