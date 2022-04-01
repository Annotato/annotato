import Foundation

extension AnnotationHandwritingEntity {
    func customUpdate(date: Date, usingUpdatedEntity updatedAnnotationHandwritingEntity: AnnotationHandwritingEntity) {
        self.copyPropertiesOf(otherEntity: updatedAnnotationHandwritingEntity)
        self.updatedAt = date
    }

    private func copyPropertiesOf(otherEntity: AnnotationHandwritingEntity) {
        precondition(id == otherEntity.id)

        handwriting = otherEntity.handwriting
        height = otherEntity.height
        order = otherEntity.order
        annotationEntity = otherEntity.annotationEntity
    }
}
