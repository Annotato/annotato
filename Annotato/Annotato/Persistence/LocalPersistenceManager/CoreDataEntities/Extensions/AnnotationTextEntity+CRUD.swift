import Foundation

extension AnnotationTextEntity {
    func customUpdate(date: Date, usingUpdatedEntity updatedAnnotationTextEntity: AnnotationTextEntity) {
        self.copyPropertiesOf(otherEntity: updatedAnnotationTextEntity)
        self.updatedAt = date
    }

    private func copyPropertiesOf(otherEntity: AnnotationTextEntity) {
        precondition(id == otherEntity.id)

        type = otherEntity.type
        content = otherEntity.content
        height = otherEntity.height
        order = otherEntity.order
        annotationEntity = otherEntity.annotationEntity
    }
}
