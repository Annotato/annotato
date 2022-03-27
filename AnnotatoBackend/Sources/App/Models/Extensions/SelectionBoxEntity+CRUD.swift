import FluentKit
import AnnotatoSharedLibrary

extension SelectionBoxEntity {
    /// Creates the SelectionBoxEntity instance. Use this function to create cascades.
    /// - Parameter tx: The database instance in a transaction.
    func customCreate(on tx: Database) async throws {
        try await self.create(on: tx).get()
    }

    /// Updates the SelectionBoxEntity instance. Use this function to cascade updates.
    /// - Parameters:
    ///   - tx: The database instance in a transaction.
    ///   - selectionBox: The updated SelectionBox instance.
    func customUpdate(on tx: Database, usingUpdatedModel selectionBox: SelectionBox) async throws {
        self.copyPropertiesOf(otherEntity: SelectionBoxEntity.fromModel(selectionBox))
        try await self.update(on: tx).get()
    }

    /// Deletes the SelectionBoxEntity instance. Use this function to cascade deletes.
    /// - Parameter tx: The database instance in a transaction.
    func customDelete(on tx: Database) async throws {
        try await self.delete(on: tx).get()
    }

    func copyPropertiesOf(otherEntity: SelectionBoxEntity) {
        precondition(id == otherEntity.id)

        startPointX = otherEntity.startPointX
        startPointY = otherEntity.startPointY
        endPointX = otherEntity.endPointX
        endPointY = otherEntity.endPointY
        $annotationEntity.id = otherEntity.$annotationEntity.id
    }
}
