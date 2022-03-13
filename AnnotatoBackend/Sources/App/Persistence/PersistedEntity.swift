import FluentKit

/// The persisted representation of a Persistable model.
/// Note: The inherited class can be switched out if we choose to move away from Fluent.
protocol PersistedEntity: Model {
    associatedtype PersistableModel: Persistable

    static func fromModel(_ model: PersistableModel) -> Self
}
