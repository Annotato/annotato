import FluentKit
import AnnotatoSharedLibrary

extension AnnotationTextEntity {
    /// Updates the AnnotationTextEntity instance.
    /// - Parameters:
    ///   - tx: The database instance in a transaction.
    ///   - annotationText: The updated AnnotationText instance.
    func customUpdate(on tx: Database, usingUpdatedModel annotationText: AnnotationText) async throws {
        self.copyPropertiesOf(otherEntity: AnnotationTextEntity.fromModel(annotationText))
        return try await self.update(on: tx).get()
    }

    /// Deletes the AnnotationTextEntity instance.
    /// - Parameter tx: The database instance in a transaction.
    func customDelete(on tx: Database) async throws {
        return try await self.delete(on: tx).get()
    }

    func copyPropertiesOf(otherEntity: AnnotationTextEntity) {
        precondition(id == otherEntity.id)

        type = otherEntity.type
        content = otherEntity.content
        height = otherEntity.height
        order = otherEntity.order
        $annotationEntity.id = otherEntity.$annotationEntity.id
    }
}
