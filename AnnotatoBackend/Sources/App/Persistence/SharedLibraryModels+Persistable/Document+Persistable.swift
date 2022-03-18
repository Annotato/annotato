import AnnotatoSharedLibrary

extension Document: Persistable {
    static func fromManagedEntity(_ managedEntity: DocumentEntity) -> Self {
        Self(
            name: managedEntity.name,
            ownerId: managedEntity.ownerId,
            baseFileUrl: managedEntity.baseFileUrl,
            id: managedEntity.id
        )
    }
}
