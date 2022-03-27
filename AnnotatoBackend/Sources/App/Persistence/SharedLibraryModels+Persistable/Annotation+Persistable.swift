import Foundation
import AnnotatoSharedLibrary

extension Annotation: Persistable {
    static func fromManagedEntity(_ managedEntity: AnnotationEntity) -> Self {
        let textParts = managedEntity.annotationTextEntities.map(AnnotationText.fromManagedEntity)
        let handwritingParts = managedEntity.annotationHandwritingEntities.map(AnnotationHandwriting.fromManagedEntity)
        let parts: [AnnotationPart] = textParts + handwritingParts

        return Self(
            origin: CGPoint(x: managedEntity.originX, y: managedEntity.originY),
            width: managedEntity.width,
            parts: parts,
            ownerId: managedEntity.ownerId,
            documentId: managedEntity.$documentEntity.id,
            id: managedEntity.id
        )
    }
}
