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

    @Children(for: \.$document)
    var annotations: [AnnotationEntity]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(id: UUID? = nil, name: String, ownerId: String, baseFileUrl: String) {
        self.id = id
        self.name = name
        self.ownerId = ownerId
        self.baseFileUrl = baseFileUrl
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
        Self(id: model.id, name: model.name, ownerId: model.ownerId, baseFileUrl: model.baseFileUrl)
    }
}
