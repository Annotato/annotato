import FluentKit
import AnnotatoSharedLibrary

final class AnnotationTextEntity: Model {
    static let schema = "annotation_text"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "type")
    var type: Int

    @Field(key: "content")
    var content: String

    @Field(key: "height")
    var height: Double

    @Field(key: "order")
    var order: Int

    @Parent(key: "annotation_id")
    var annotation: AnnotationEntity

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        type: AnnotationType,
        content: String,
        height: Double,
        order: Int,
        annotationId: AnnotationEntity.IDValue,
        id: UUID? = nil
    ) {
        self.id = id
        self.type = type.rawValue
        self.content = content
        self.height = height
        self.order = order
        self.$annotation.id = annotationId
    }
}

extension AnnotationTextEntity: PersistedEntity {
    static func fromModel(_ model: AnnotationText) -> Self {
        Self(
            type: model.type,
            content: model.content,
            height: model.height,
            order: model.order,
            annotationId: model.annotationId,
            id: model.id
        )
    }
}
