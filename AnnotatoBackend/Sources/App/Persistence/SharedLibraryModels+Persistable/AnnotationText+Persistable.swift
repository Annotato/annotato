import CoreGraphics
import Foundation
import AnnotatoSharedLibrary

extension AnnotationText: Persistable {
    static func fromManagedEntity(_ managedEntity: AnnotationTextEntity) -> Self {
        Self(
            type: AnnotationType(rawValue: managedEntity.type) ?? .plainText,
            content: managedEntity.content,
            height: managedEntity.height,
            annotationId: managedEntity.$annotation.id,
            id: managedEntity.id
        )
    }
}
