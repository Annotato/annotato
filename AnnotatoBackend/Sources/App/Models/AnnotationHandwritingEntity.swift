import Foundation
import FluentKit
import AnnotatoSharedLibrary

final class AnnotationHandwritingEntity: Model {
    static let schema = "annotation_handwritings"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "handwriting")
    var handwriting: Data

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

    init() { }

    init(
        handwriting: Data,
        height: Double,
        order: Int,
        annotationId: AnnotationEntity.IDValue,
        id: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.handwriting = handwriting
        self.height = height
        self.order = order
        self.$annotationEntity.id = annotationId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

extension AnnotationHandwritingEntity: PersistedEntity {
    static func fromModel(_ model: AnnotationHandwriting) -> Self {
        Self(
            handwriting: model.handwriting,
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
