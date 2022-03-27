import CoreGraphics
import Foundation
import AnnotatoSharedLibrary

extension Annotation: Persistable {
    static func fromManagedEntity(_ managedEntity: AnnotationEntity) -> Self {
        let textParts = managedEntity.annotationTextEntities.map(AnnotationText.fromManagedEntity)
        let parts: [AnnotationPart] = textParts
        let selectionBox = SelectionBox.fromManagedEntity(managedEntity.selectionBox)

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
