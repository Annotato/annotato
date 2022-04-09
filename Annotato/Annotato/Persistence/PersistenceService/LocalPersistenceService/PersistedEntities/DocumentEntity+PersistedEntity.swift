import AnnotatoSharedLibrary

extension DocumentEntity: PersistedEntity {
    static func fromModel(_ model: Document) -> DocumentEntity {
        let entity = LocalPersistenceService.makeCoreDataEntity(class: Document.self)

        entity.id = model.id
        entity.name = model.name
        entity.ownerId = model.ownerId
        entity.baseFileUrl = model.baseFileUrl

        model.annotations.forEach({ entity.addToAnnotationEntities(AnnotationEntity.fromModel($0)) })

        entity.createdAt = model.createdAt
        entity.updatedAt = model.updatedAt
        entity.deletedAt = model.deletedAt

        return entity
    }
}
