import FluentKit

struct CreateSelectionBoxes: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(SelectionBoxEntity.schema)
            .id()
            .field("start_point_x", .double, .required)
            .field("start_point_y", .double, .required)
            .field("end_point_x", .double, .required)
            .field("end_point_y", .double, .required)
            .field("annotation_id", .uuid, .required, .references(AnnotationEntity.schema, "id", onDelete: .cascade))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(SelectionBoxEntity.schema)
            .delete()
    }
}
