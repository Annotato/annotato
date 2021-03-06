import Foundation
import FluentKit
import AnnotatoSharedLibrary

final class AnnotationTextEntity: Model {
    static let schema = "annotation_text"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "type")
    var type: Int64

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

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    var isDeleted: Bool {
        deletedAt != nil
    }

    init() { }

    init(
        type: AnnotationText.TextType,
        content: String,
        height: Double,
        order: Int,
        annotationId: AnnotationEntity.IDValue,
        id: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.type = type.rawValue
        self.content = content
        self.height = height
        self.order = order
        self.$annotationEntity.id = annotationId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
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
            id: model.id,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt,
            deletedAt: model.deletedAt
        )
    }
}
