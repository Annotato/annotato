import FluentKit
import AnnotatoSharedLibrary

extension SelectionBoxEntity {
    /// Creates the SelectionBoxEntity instance.
    /// - Parameter tx: The database instance in a transaction.
    func customCreate(on tx: Database) async throws {
        try await self.create(on: tx).get()
    }

    /// Updates the SelectionBoxEntity instance.
    /// - Parameters:
    ///   - tx: The database instance in a transaction.
    ///   - selectionBox: The updated SelectionBox instance.
    func customUpdate(on tx: Database, usingUpdatedModel selectionBox: SelectionBox) async throws {
        if selectionBox.isDeleted && !self.isDeleted {
            try await self.customDelete(on: tx)
            return
        }

        if selectionBox.isDeleted {
            return
        }

        try await self.restore(on: tx)
        self.copyPropertiesOf(otherEntity: SelectionBoxEntity.fromModel(selectionBox))
        try await self.update(on: tx).get()
    }

    /// Deletes the SelectionBoxEntity instance.
    /// - Parameter tx: The database instance in a transaction.
    func customDelete(on tx: Database) async throws {
        try await self.restore(on: tx)
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
