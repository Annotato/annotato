import Foundation
import AnnotatoSharedLibrary

extension Document: Persistable {
    static func fromManagedEntity(_ managedEntity: DocumentEntity) -> Self {
        let document = Self(
            name: managedEntity.name,
            ownerId: managedEntity.ownerId,
            baseFileUrl: managedEntity.baseFileUrl,
            id: managedEntity.id
        )

        managedEntity.annotations.forEach { annotationEntity in
            document.addAnnotation(annotation: Annotation.fromManagedEntity(annotationEntity))
        }

        return document
    }
}
