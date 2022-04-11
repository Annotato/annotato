import FluentKit
import Foundation
import AnnotatoSharedLibrary

final class UserEntity: Model {
    static let schema = "users"

    typealias IDValue = String

    @ID(custom: "id")
    var id: String?

    @Field(key: "email")
    var email: String

    @Field(key: "display_name")
    var displayName: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() { }

    init(
        id: String,
        email: String,
        displayName: String,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

extension UserEntity: PersistedEntity {
    static func fromModel(_ model: AnnotatoUser) -> Self {
        Self(
            id: model.id,
            email: model.email,
            displayName: model.displayName,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt,
            deletedAt: model.deletedAt
        )
    }
}
