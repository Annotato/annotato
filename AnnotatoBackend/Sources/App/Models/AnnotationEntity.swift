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

    init() { }

    init(
        id: UUID? = nil,
        originX: Double,
        originY: Double,
        width: Double,
        ownerId: String,
        documentId: DocumentEntity.IDValue
    ) {
        self.id = id
        self.originX = originX
        self.originY = originY
        self.width = width
        self.ownerId = ownerId
        self.$document.id = documentId
    }
}

extension AnnotationEntity: PersistedEntity {
    static func fromModel(_ model: Annotation) -> Self {
        Self(
            id: model.id,
            originX: model.origin.x,
            originY: model.origin.y,
            width: model.width,
            ownerId: model.ownerId,
            documentId: model.documentId
        )
    }
}
