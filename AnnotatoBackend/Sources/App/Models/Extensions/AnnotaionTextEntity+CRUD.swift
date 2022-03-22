import FluentKit
import AnnotatoSharedLibrary

extension AnnotationTextEntity {
    func copyPropertiesOf(otherEntity: AnnotationTextEntity) {
        precondition(id == otherEntity.id)

        type = otherEntity.type
        content = otherEntity.content
        height = otherEntity.height
        order = otherEntity.order
        $annotationEntity.id = otherEntity.$annotationEntity.id
    }

    func customUpdate(on tx: Database, usingUpdatedModel annotationText: AnnotationText) async throws {
        self.copyPropertiesOf(otherEntity: AnnotationTextEntity.fromModel(annotationText))
        return try await self.update(on: tx).get()
    }

    func customDelete(on tx: Database) async throws {
        return try await self.delete(on: tx).get()
    }
}
