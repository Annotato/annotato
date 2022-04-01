import AnnotatoSharedLibrary

extension AnnotationTextEntity: PersistedEntity {
    static func fromModel(_ model: AnnotationText) -> AnnotationTextEntity {
        let context = LocalPersistenceManager.sharedContext
        let entity = AnnotationTextEntity(context: context)

        entity.id = model.id
        entity.type = model.type
        entity.order = Int64(model.order)
        entity.height = model.height
        entity.content = model.content

        if let annotationEntity = LocalAnnotationEntityDataAccess.read(annotationId: model.annotationId) {
            entity.annotationEntity = annotationEntity
        }

        entity.createdAt = model.createdAt
        entity.updatedAt = model.updatedAt
        entity.deletedAt = model.deletedAt

        return entity
    }
}
