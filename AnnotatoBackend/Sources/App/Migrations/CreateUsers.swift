import FluentKit

struct CreateUsers: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(UserEntity.schema)
            .field("id", .string, .identifier(auto: false))
            .field("email", .string, .required)
            .field("display_name", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(UserEntity.schema)
            .delete()
    }
}
