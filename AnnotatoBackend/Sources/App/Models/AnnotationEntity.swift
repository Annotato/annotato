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
    var ownerId: UUID

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() { }

    init(originX: Double, originY: Double, ownerId: UUID, id: UUID? = nil) {
        self.originX = originX
        self.originY = originY
        self.ownerId = ownerId
        self.id = id
    }
}

extension AnnotationEntity: PersistedEntity {
    static func fromModel(_ model: Annotation) -> Self {
        Self(originX: model.origin.x, originY: model.origin.y, ownerId: model.ownerId, id: model.id)
    }
}
