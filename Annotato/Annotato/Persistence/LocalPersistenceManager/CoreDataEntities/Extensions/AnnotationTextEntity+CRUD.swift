import Foundation

extension AnnotationTextEntity {
    func customCreate(date: Date) {
        self.createdAt = date
    }

    func customUpdate(date: Date, usingUpdatedEntity updatedAnnotationTextEntity: AnnotationTextEntity) {
        self.copyPropertiesOf(otherEntity: updatedAnnotationTextEntity)
        self.updatedAt = date
    }

    func customDelete(date: Date) {
        self.deletedAt = date
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
