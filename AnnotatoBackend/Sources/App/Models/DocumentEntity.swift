import Foundation
import FluentKit
import AnnotatoSharedLibrary

final class DocumentEntity: Model {
    static let schema = "documents"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "owner_id")
    var ownerId: String

    @Field(key: "base_file_url")
    var baseFileUrl: String

    @Children(for: \.$documentEntity)
    var annotationEntities: [AnnotationEntity]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    var isDeleted: Bool {
        deletedAt != nil
    }

    init() { }

    init(
        name: String,
        ownerId: String,
        baseFileUrl: String,
        id: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.ownerId = ownerId
        self.baseFileUrl = baseFileUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

extension DocumentEntity: PersistedEntity {
    static func fromModel(_ model: Document) -> Self {
        Self(
            name: model.name,
            ownerId: model.ownerId,
            baseFileUrl: model.baseFileUrl,
            id: model.id,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt,
            deletedAt: model.deletedAt
        )
    }
}
