import AnnotatoSharedLibrary

extension AnnotationHandwritingEntity: PersistedEntity {
    static func fromModel(_ model: AnnotationHandwriting) -> AnnotationHandwritingEntity {
        let entity = LocalPersistenceService.makeCoreDataEntity(class: AnnotationHandwriting.self)

        entity.id = model.id
        entity.order = Int64(model.order)
        entity.height = model.height
        entity.handwriting = model.handwriting

        if let annotationEntity = Self.localAnnotationEntityDataAccess
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
