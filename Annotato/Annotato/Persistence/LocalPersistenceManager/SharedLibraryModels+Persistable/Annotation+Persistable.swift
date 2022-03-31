import Foundation
import CoreGraphics
import AnnotatoSharedLibrary

extension Annotation: Persistable {
    static func fromManagedEntity(_ managedEntity: AnnotationEntity) -> Self {
        let textParts = Array(managedEntity.annotationTextEntities)
            .map(AnnotationText.fromManagedEntity)
        let handwritingParts = Array(managedEntity.annotationHandwritingEntities)
            .map(AnnotationHandwriting.fromManagedEntity)
        let parts: [AnnotationPart] = textParts + handwritingParts

        // TODO: SELECTION BOX
    }
}
