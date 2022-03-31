import Foundation

extension AnnotationEntity {
    func customCreate(date: Date) {
        self.createdAt = date
        self.annotationTextEntities.forEach({ $0.customCreate(date: date) })
        self.annotationHandwritingEntities.forEach({ $0.customCreate(date: date) })

        // TODO: SELECTION BOX
    }

    func customUpdate(date: Date, usingUpdatedEntity updatedAnnotationEntity: AnnotationEntity) {
        self.pruneOldAssociations(date: date, usingUpdatedEntity: updatedAnnotationEntity)
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

    func customDelete(date: Date) {
        self.deletedAt = date
        self.annotationTextEntities.forEach({ $0.customDelete(date: date) })
        self.annotationHandwritingEntities.forEach({ $0.customDelete(date: date) })

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

    private func pruneOldAssociations(date: Date, usingUpdatedEntity updatedAnnotationEntity: AnnotationEntity) {
        for annotationTextEntity in annotationTextEntities
        where !updatedAnnotationEntity.annotationTextEntities
            .contains(where: { $0.id == annotationTextEntity.id }) {
                annotationTextEntity.customDelete(date: date)
            }

        for annotationHandwritingEntity in annotationHandwritingEntities
        where !updatedAnnotationEntity.annotationHandwritingEntities
            .contains(where: { $0.id == annotationHandwritingEntity.id }) {
                annotationHandwritingEntity.customDelete(date: date)
            }
    }
}
