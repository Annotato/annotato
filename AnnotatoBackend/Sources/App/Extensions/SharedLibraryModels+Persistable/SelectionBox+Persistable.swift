import Foundation
import AnnotatoSharedLibrary

extension SelectionBox: Persistable {
    static func fromManagedEntity(_ managedEntity: SelectionBoxEntity) -> Self {
        Self(
            startPoint: CGPoint(x: managedEntity.startPointX, y: managedEntity.startPointY),
            endPoint: CGPoint(x: managedEntity.endPointX, y: managedEntity.endPointY),
            annotationId: managedEntity.$annotationEntity.id,
            id: managedEntity.id,
            createdAt: managedEntity.createdAt,
            updatedAt: managedEntity.updatedAt,
            deletedAt: managedEntity.deletedAt
        )
    }
}
