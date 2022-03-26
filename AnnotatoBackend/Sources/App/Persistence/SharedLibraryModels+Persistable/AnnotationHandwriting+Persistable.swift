import Foundation
import AnnotatoSharedLibrary

extension AnnotationHandwriting: Persistable {
    static func fromManagedEntity(_ managedEntity: AnnotationHandwritingEntity) -> Self {
        Self(
            order: managedEntity.order,
            height: managedEntity.height,
            annotationId: managedEntity.$annotationEntity.id,
            handwriting: managedEntity.handwriting,
            id: managedEntity.id
        )
    }
}
