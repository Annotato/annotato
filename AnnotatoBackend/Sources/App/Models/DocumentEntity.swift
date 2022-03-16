import FluentKit
import AnnotatoSharedLibrary

final class DocumentEntity: Model {
    static let schema = "documents"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "owner_id")
    var ownerId: UUID

    @Field(key: "base_file_url")
    var baseFileUrl: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() { }

    init(name: String, ownerId: UUID, baseFileUrl: String, id: UUID? = nil) {
        self.name = name
        self.ownerId = ownerId
        self.baseFileUrl = baseFileUrl
        self.id = id
    }

    func copyPropertiesOf(otherEntity: DocumentEntity) {
        precondition(id == otherEntity.id)

        name = otherEntity.name
        ownerId = otherEntity.ownerId
        baseFileUrl = otherEntity.baseFileUrl
    }
}

extension DocumentEntity: PersistedEntity {
    static func fromModel(_ model: Document) -> Self {
        Self(name: model.name, ownerId: model.ownerId, baseFileUrl: model.baseFileUrl, id: model.id)
    }
}
