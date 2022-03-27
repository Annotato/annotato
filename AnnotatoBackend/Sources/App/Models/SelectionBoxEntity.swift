import FluentKit
import AnnotatoSharedLibrary

final class SelectionBoxEntity: Model {
    static let schema = "selection_box"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "start_point_x")
    var startPointX: Double

    @Field(key: "start_point_y")
    var startPointY: Double

    @Field(key: "end_point_x")
    var endPointX: Double

    @Field(key: "end_point_y")
    var endPointY: Double

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
        startPointX: Double,
        startPointY: Double,
        endPointX: Double,
        endPointY: Double
        id: UUID? = nil
    ) {
        self.id = id
        self.startPointX = startPointX
        self.startPointY = startPointY
        self.endPointX = endPointX
        self.endPointY = endPointY
    }
}

extension SelectionBoxEntity: PersistedEntity {
    static func fromModel(_ model: SelectionBox) -> Self {
        Self(
            startPointX: model.startPoint.x,
            startPointY: model.startPoint.y,
            endPointX: model.endPoint.x,
            endPointY: model.endPoint.y,
            id: model.id
        )
    }
}