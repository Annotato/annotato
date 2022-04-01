import AnnotatoSharedLibrary

extension DocumentShareEntity: PersistedEntity {
    static func fromModel(_ model: DocumentShare) -> DocumentShareEntity {
        let context = LocalPersistenceManager.sharedContext
        let entity = DocumentShareEntity(context: context)

        entity.id = model.id
        entity.recipientId = model.recipientId

        if let documentEntity = LocalDocumentEntityDataAccess.read(documentId: model.documentId) {
            entity.documentEntity = documentEntity
        }

        entity.createdAt = model.createdAt
        entity.updatedAt = model.updatedAt
        entity.deletedAt = model.deletedAt

        return entity
    }
}
