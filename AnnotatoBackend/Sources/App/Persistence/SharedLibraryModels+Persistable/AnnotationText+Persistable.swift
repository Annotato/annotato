import CoreGraphics
import Foundation
import AnnotatoSharedLibrary

extension AnnotationText: Persistable {
    static func fromManagedEntity(_ managedEntity: AnnotationTextEntity) -> Self {
        Self(
            type: TextType(rawValue: managedEntity.type) ?? .plainText,
            content: managedEntity.content,
            height: managedEntity.height,
            order: managedEntity.order,
            annotationId: managedEntity.$annotationEntity.id,
            id: managedEntity.id
        )
    }
}
