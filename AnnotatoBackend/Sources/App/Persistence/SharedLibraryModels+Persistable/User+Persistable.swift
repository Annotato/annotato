import AnnotatoSharedLibrary

extension User: Persistable {
    static func fromManagedEntity(_ managedEntity: UserEntity) -> Self {
        Self(
            displayName: managedEntity.displayName,
            id: managedEntity.id,
            createdAt: managedEntity.createdAt,
            updatedAt: managedEntity.updatedAt,
            deletedAt: managedEntity.deletedAt
        )
    }
}
