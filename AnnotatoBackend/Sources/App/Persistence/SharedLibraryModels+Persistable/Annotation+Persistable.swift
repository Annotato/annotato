import Foundation
import AnnotatoSharedLibrary

extension Annotation: Persistable {
    static func fromManagedEntity(_ managedEntity: AnnotationEntity) -> Self {
        let textParts = managedEntity.annotationTextEntities.map(AnnotationText.fromManagedEntity)
        let handwritingParts = managedEntity.annotationHandwritingEntities.map(AnnotationHandwriting.fromManagedEntity)
        let parts: [AnnotationPart] = textParts + handwritingParts

        let selectionBox: SelectionBox
        if let selectionBoxEntity = managedEntity.selectionBox {
            selectionBox = SelectionBox.fromManagedEntity(selectionBoxEntity)
        } else {
            // Will never come to this part
            fatalError("This annotation entity has no associated selection box.")
            /*
             selectionBox = SelectionBox(startPoint: .zero, endPoint: .zero, annotationId: managedEntity.id ?? UUID(), id: UUID())
             */
        }

        return Self(
            origin: CGPoint(x: managedEntity.originX, y: managedEntity.originY),
            width: managedEntity.width,
            parts: parts,
            selectionBox: selectionBox,
            ownerId: managedEntity.ownerId,
            documentId: managedEntity.$documentEntity.id,
            id: managedEntity.id
        )
    }
}
