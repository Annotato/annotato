import Foundation

extension AnnotationHandwritingEntity {
    func customCreate(date: Date) {
        self.createdAt = date
    }

    func customUpdate(date: Date, usingUpdatedEntity updatedAnnotationHandwritingEntity: AnnotationHandwritingEntity) {
        self.copyPropertiesOf(otherEntity: updatedAnnotationHandwritingEntity)
        self.updatedAt = date
    }

    func customDelete(date: Date) {
        self.deletedAt = date
    }

    private func copyPropertiesOf(otherEntity: AnnotationHandwritingEntity) {
        precondition(id == otherEntity.id)

        handwriting = otherEntity.handwriting
        height = otherEntity.height
        order = otherEntity.order
        annotationEntity = otherEntity.annotationEntity
    }
}
