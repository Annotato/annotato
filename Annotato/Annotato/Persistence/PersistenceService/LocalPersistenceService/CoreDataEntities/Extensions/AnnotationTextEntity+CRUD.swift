import AnnotatoSharedLibrary

extension AnnotationTextEntity {
    func customUpdate(usingUpdatedModel annotationText: AnnotationText) {
        self.copyPropertiesOf(updatedModel: annotationText)
    }

    private func copyPropertiesOf(updatedModel annotationText: AnnotationText) {
        precondition(id == annotationText.id)

        type = annotationText.type
        content = annotationText.content
        height = annotationText.height
        order = Int64(annotationText.order)

        if let annotationEntity = LocalAnnotationEntityDataAccess()
            .readInCurrentContext(annotationId: annotationText.annotationId,
                                  withDeleted: true) {
            self.annotationEntity = annotationEntity
        }

        createdAt = annotationText.createdAt
        updatedAt = annotationText.updatedAt
        deletedAt = annotationText.deletedAt
    }
}
