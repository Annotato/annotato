import AnnotatoSharedLibrary

extension AnnotationHandwritingEntity: PersistedEntity {
    static func fromModel(_ model: AnnotationHandwriting) -> AnnotationHandwritingEntity {
        let context = LocalPersistenceManager.sharedContext
        let entity = AnnotationHandwritingEntity(context: context)

        entity.id = model.id
        entity.order = Int64(model.order)
        entity.height = model.height
        entity.handwriting = model.handwriting

        if let annotationEntity = LocalAnnotationEntityDataAccess.read(annotationId: model.annotationId) {
            entity.annotationEntity = annotationEntity
        }

        // TODO: Set Timestamps

        return entity
    }
}
