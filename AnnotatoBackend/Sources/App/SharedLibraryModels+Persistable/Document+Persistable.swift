import AnnotatoSharedLibrary

extension Document: Persistable {
    typealias PersistedEntity = DocumentEntity

    static func fromManagedEntity(_ managedEntity: DocumentEntity) -> Self {
        Self(name: managedEntity.name, ownerId: managedEntity.ownerId,
             baseFileUrl: managedEntity.baseFileUrl, id: managedEntity.id)
    }
}
