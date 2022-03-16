import CoreGraphics
import AnnotatoSharedLibrary

extension AnnotationText: Persistable {
    static func fromManagedEntity(_ managedEntity: AnnotationTextEntity) -> Self {
        Self(
            type: AnnotationType(rawValue: managedEntity.type) ?? .plainText,
            content: managedEntity.content,
            height: managedEntity.height,
            annotationId: managedEntity.annotationId,
            id: managedEntity.id
        )
    }
}
