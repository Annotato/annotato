import Foundation
import FluentKit

struct CreateAnnotationText: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AnnotationTextEntity.schema)
            .id()
            .field("type", .int, .required)
            .field("content", .string, .required)
            .field("height", .double, .required)
            .field("annotation_id", .uuid, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AnnotationTextEntity.schema)
            .delete()
    }
}
