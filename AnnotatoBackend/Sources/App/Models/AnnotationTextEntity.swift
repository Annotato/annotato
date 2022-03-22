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
    var annotationEntity: AnnotationEntity

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        type: AnnotationText.TextType,
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
        self.$annotationEntity.id = annotationId
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

extension AnnotationTextEntity {
    func copyPropertiesOf(otherEntity: AnnotationTextEntity) {
        precondition(id == otherEntity.id)

        type = otherEntity.type
        content = otherEntity.content
        height = otherEntity.height
        order = otherEntity.order
        $annotationEntity.id = otherEntity.$annotationEntity.id
    }
    
    func customUpdate(on tx: Database, usingUpdatedModel annotationText: AnnotationText) async throws {
        self.copyPropertiesOf(otherEntity: AnnotationTextEntity.fromModel(annotationText))
        return try await self.update(on: tx).get()
    }

    func customDelete(on tx: Database) async throws {
        return try await self.delete(on: tx).get()
    }
}
