import Foundation
import AnnotatoSharedLibrary

extension Annotation: Persistable {
    static func fromManagedEntity(_ managedEntity: AnnotationEntity) -> Self {
        let textParts = managedEntity.annotationTextEntities.map(AnnotationText.fromManagedEntity)
        let parts: [AnnotationPart] = textParts
        let selectionBox: SelectionBox
        if let selectionBoxEntity = managedEntity.selectionBox {
            selectionBox = SelectionBox.fromManagedEntity(selectionBoxEntity)
        } else {
            selectionBox = SelectionBox(startPoint: .zero, endPoint: .zero, id: UUID())
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
