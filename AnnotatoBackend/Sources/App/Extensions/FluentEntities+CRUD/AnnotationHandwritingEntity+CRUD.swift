import Foundation
import FluentKit
import AnnotatoSharedLibrary

extension AnnotationHandwritingEntity {
    /// Creates the AnnotationHandwritingEntity instance.
    /// - Parameter tx: The database instance in a transaction.
    func customCreate(on tx: Database) async throws {
        try await self.create(on: tx).get()
    }

    /// Updates the AnnotationHandwritingEntity instance.
    /// - Parameters:
    ///   - tx: The database instance in a transaction.
    ///   - annotationHandwriting: The updated AnnotationHandwriting instance.
    func customUpdate(on tx: Database, usingUpdatedModel annotationHandwriting: AnnotationHandwriting) async throws {
        if annotationHandwriting.isDeleted && !self.isDeleted {
            try await self.customDelete(on: tx)
            return
        }

        if annotationHandwriting.isDeleted {
            return
        }

        try await self.restore(on: tx)
        self.copyPropertiesOf(otherEntity: AnnotationHandwritingEntity.fromModel(annotationHandwriting))
        try await self.update(on: tx).get()
    }

    /// Deletes the AnnotationHandwritingEntity instance.
    /// - Parameter tx: The database instance in a transaction.
    func customDelete(on tx: Database) async throws {
        try await self.restore(on: tx)
        try await self.delete(on: tx).get()
    }

    func copyPropertiesOf(otherEntity: AnnotationHandwritingEntity) {
        precondition(id == otherEntity.id)

        handwriting = otherEntity.handwriting
        height = otherEntity.height
        order = otherEntity.order
        $annotationEntity.id = otherEntity.$annotationEntity.id
    }
}
