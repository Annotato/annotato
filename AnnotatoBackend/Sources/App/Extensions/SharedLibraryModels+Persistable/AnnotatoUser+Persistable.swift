import AnnotatoSharedLibrary

extension AnnotatoUser: Persistable {
    static func fromManagedEntity(_ managedEntity: UserEntity) -> Self {
        Self(
            email: managedEntity.email,
            displayName: managedEntity.displayName,
            id: managedEntity.id,
            createdAt: managedEntity.createdAt,
            updatedAt: managedEntity.updatedAt,
            deletedAt: managedEntity.deletedAt
        )
    }
}
