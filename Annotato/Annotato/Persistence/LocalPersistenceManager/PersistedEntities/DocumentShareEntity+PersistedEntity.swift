import AnnotatoSharedLibrary

extension DocumentShareEntity: PersistedEntity {
    static func fromModel(_ model: DocumentShare) -> DocumentShareEntity {
        let entity = LocalPersistenceManager.shared.makeCoreDataEntity(class: DocumentShare.self)

        entity.id = model.id
        entity.recipientId = model.recipientId
        // SET document

        return entity
    }
}
