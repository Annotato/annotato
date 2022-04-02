import Foundation
import CoreGraphics
import AnnotatoSharedLibrary

extension Annotation: Persistable {
    static func fromManagedEntity(_ managedEntity: AnnotationEntity) -> Self {
        let textParts = Array(managedEntity.annotationTextEntities)
            .map(AnnotationText.fromManagedEntity)
        let handwritingParts = Array(managedEntity.annotationHandwritingEntities)
            .map(AnnotationHandwriting.fromManagedEntity)
        let parts: [AnnotationPart] = textParts + handwritingParts

        let selectionBox = SelectionBox.fromManagedEntity(managedEntity.selectionBoxEntity)

        return Self(
            origin: CGPoint(x: managedEntity.originX, y: managedEntity.originY),
            width: managedEntity.width,
            parts: parts,
            selectionBox: selectionBox,
            ownerId: managedEntity.ownerId,
            documentId: managedEntity.documentId,
            id: managedEntity.id,
            createdAt: managedEntity.createdAt,
            updatedAt: managedEntity.updatedAt,
            deletedAt: managedEntity.deletedAt
        )
    }
}
