import AnnotatoSharedLibrary

extension AnnotationTextEntity: PersistedEntity {
    static func fromModel(_ model: AnnotationText) -> AnnotationTextEntity {
        let entity = LocalPersistenceService.makeCoreDataEntity(class: AnnotationText.self)

        entity.id = model.id
        entity.type = model.type
        entity.order = Int64(model.order)
        entity.height = model.height
        entity.content = model.content

        if let annotationEntity = localAnnotationEntityDataAccess
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
