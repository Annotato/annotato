/// Represents a model that can be persisted into a data store.
protocol Persistable {
    associatedtype ManagedEntity: PersistedEntity

    static func fromManagedEntity(_ managedEntity: ManagedEntity) -> Self
}
