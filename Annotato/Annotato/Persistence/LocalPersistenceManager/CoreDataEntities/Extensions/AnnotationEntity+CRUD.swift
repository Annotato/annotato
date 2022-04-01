import Foundation

extension AnnotationEntity {
    func customUpdate(date: Date, usingUpdatedEntity updatedAnnotationEntity: AnnotationEntity) {
        self.copyPropertiesOf(otherEntity: updatedAnnotationEntity)

        for annotationTextEntity in annotationTextEntities {
            if let existingAnnotationTextEntity = LocalAnnotationTextEntityDataAccess
                .read(annotationTextEntityId: annotationTextEntity.id) {
                existingAnnotationTextEntity.customUpdate(date: date, usingUpdatedEntity: annotationTextEntity)
            }
        }

        for annotationHandwritingEntity in annotationHandwritingEntities {
            if let existingAnnotationHandwritingEntity = LocalAnnotationHandwritingEntityDataAccess
                .read(annotationHandwritingEntityId: annotationHandwritingEntity.id) {
                existingAnnotationHandwritingEntity.customUpdate(
                    date: date, usingUpdatedEntity: annotationHandwritingEntity
                )
            }
        }

        // TODO: SELECTION BOX
    }

    private func copyPropertiesOf(otherEntity: AnnotationEntity) {
        precondition(id == otherEntity.id)

        originX = otherEntity.originX
        originY = otherEntity.originY
        width = otherEntity.width
        ownerId = otherEntity.ownerId
        documentEntity = otherEntity.documentEntity
    }
}
