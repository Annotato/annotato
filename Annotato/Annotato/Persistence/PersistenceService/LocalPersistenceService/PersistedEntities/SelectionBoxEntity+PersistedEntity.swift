import AnnotatoSharedLibrary

extension SelectionBoxEntity: PersistedEntity {
    static func fromModel(_ model: SelectionBox) -> SelectionBoxEntity {
        let entity = LocalPersistenceService.makeCoreDataEntity(class: SelectionBox.self)

        entity.id = model.id
        entity.startPointX = model.startPoint.x
        entity.startPointY = model.startPoint.y
        entity.endPointX = model.endPoint.x
        entity.endPointY = model.endPoint.y

        if let annotationEntity = LocalAnnotationEntityDataAccess
            .readInCurrentContext(annotationId: model.annotationId,
                                  withDeleted: true) {
            entity.annotationEntity = annotationEntity
        }

        entity.createdAt = model.createdAt
        entity.updatedAt = model.updatedAt
        entity.deletedAt = model.deletedAt

        return entity
    }
}
