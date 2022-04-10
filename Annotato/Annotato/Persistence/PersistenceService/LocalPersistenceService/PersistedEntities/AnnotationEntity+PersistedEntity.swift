import AnnotatoSharedLibrary

extension AnnotationEntity: PersistedEntity {
    static func fromModel(_ model: Annotation) -> AnnotationEntity {
        let entity = LocalPersistenceService.makeCoreDataEntity(class: Annotation.self)

        entity.id = model.id
        entity.width = model.width
        entity.ownerId = model.ownerId
        entity.originX = model.origin.x
        entity.originY = model.origin.y

        if let documentEntity = Self.localDocumentEntityDataAccess
            .readInCurrentContext(documentId: model.documentId,
                                  withDeleted: true) {
            entity.documentEntity = documentEntity
        }

        entity.selectionBoxEntity = SelectionBoxEntity.fromModel(model.selectionBox)

        let annotationTexts = model.parts.compactMap({ $0 as? AnnotationText })
        annotationTexts.forEach({
            entity.addToAnnotationTextEntities(AnnotationTextEntity.fromModel($0))
        })

        let annotationHandwritings = model.parts.compactMap({ $0 as? AnnotationHandwriting })
        annotationHandwritings.forEach({
            entity.addToAnnotationHandwritingEntities(AnnotationHandwritingEntity.fromModel($0))
        })

        entity.createdAt = model.createdAt
        entity.updatedAt = model.updatedAt
        entity.deletedAt = model.deletedAt

        return entity
    }
}
