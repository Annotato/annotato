import FluentKit
import AnnotatoSharedLibrary

final class AnnotationEntity: Model {
    static let schema = "annotations"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "origin_x")
    var originX: Double

    @Field(key: "origin_y")
    var originY: Double

    @Field(key: "width")
    var width: Double

    @Field(key: "owner_id")
    var ownerId: String

    @Parent(key: "document_id")
    var document: DocumentEntity

    @Children(for: \.$annotation)
    var annotationTextEntities: [AnnotationTextEntity]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() { }

    init(originX: Double, originY: Double, ownerId: String, documentId: DocumentEntity.IDValue, id: UUID? = nil) {
        self.originX = originX
        self.originY = originY
        self.ownerId = ownerId
        self.$document.id = documentId
        self.id = id
    }
}

extension AnnotationEntity: PersistedEntity {
    static func fromModel(_ model: Annotation) -> Self {
        Self(
            originX: model.origin.x,
            originY: model.origin.y,
            ownerId: model.ownerId,
            documentId: model.documentId,
            id: model.id
        )
    }
}
