import CoreGraphics
import AnnotatoSharedLibrary

extension Annotation: Persistable {
    static func fromManagedEntity(_ managedEntity: AnnotationEntity) -> Self {
        Self(
            origin: CGPoint(x: managedEntity.originX, y: managedEntity.originY),
            width: managedEntity.width,
            ownerId: managedEntity.ownerId,
            documentId: managedEntity.documentId,
            id: managedEntity.id
        )
    }
}
