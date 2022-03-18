import Foundation
import AnnotatoSharedLibrary

extension Document: Persistable {
    static func fromManagedEntity(_ managedEntity: DocumentEntity) -> Self {
        let document = Self(
            id: managedEntity.id,
            name: managedEntity.name,
            ownerId: managedEntity.ownerId,
            baseFileUrl: managedEntity.baseFileUrl
        )

        managedEntity.annotations.forEach { annotationEntity in
            document.addAnnotation(annotation: Annotation.fromManagedEntity(annotationEntity))
        }

        return document
    }
}
