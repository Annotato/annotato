import CoreGraphics
import Foundation
import AnnotatoSharedLibrary

extension Annotation: Persistable {
    static func fromManagedEntity(_ managedEntity: AnnotationEntity) -> Self {
        Self(
            id: managedEntity.id,
            origin: CGPoint(x: managedEntity.originX, y: managedEntity.originY),
            width: managedEntity.width,
            ownerId: managedEntity.ownerId,
            documentId: managedEntity.$document.id
        )
    }
}
