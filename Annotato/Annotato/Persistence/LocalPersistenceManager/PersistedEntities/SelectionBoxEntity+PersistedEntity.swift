import AnnotatoSharedLibrary

extension SelectionBoxEntity: PersistedEntity {
    static func fromModel(_ model: SelectionBox) -> SelectionBoxEntity {
        let context = LocalPersistenceManager.sharedContext
        let entity = SelectionBoxEntity(context: context)

        entity.id = model.id
        entity.startPointX = model.startPoint.x
        entity.startPointY = model.startPoint.y
        entity.endPointX = model.endPoint.x
        entity.endPointY = model.endPoint.y

        if let annotationEntity = LocalAnnotationEntityDataAccess.read(annotationId: model.annotationId) {
            entity.annotationEntity = annotationEntity
        }

        entity.createdAt = model.createdAt
        entity.updatedAt = model.updatedAt
        entity.deletedAt = model.deletedAt

        return entity
    }
}
