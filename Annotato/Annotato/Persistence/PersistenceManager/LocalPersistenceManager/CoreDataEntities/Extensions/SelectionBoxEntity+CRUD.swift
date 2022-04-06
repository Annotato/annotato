import AnnotatoSharedLibrary

extension SelectionBoxEntity {
    func customUpdate(usingUpdatedModel selectionBox: SelectionBox) {
        self.copyPropertiesOf(updatedModel: selectionBox)
    }

    func copyPropertiesOf(updatedModel selectionBox: SelectionBox) {
        precondition(id == selectionBox.id)

        startPointX = selectionBox.startPoint.x
        startPointY = selectionBox.startPoint.y
        endPointX = selectionBox.endPoint.x
        endPointY = selectionBox.endPoint.y

        if let annotationEntity = LocalAnnotationEntityDataAccess
            .readInCurrentContext(annotationId: selectionBox.annotationId,
                                  withDeleted: true) {
            self.annotationEntity = annotationEntity
        }

        createdAt = selectionBox.createdAt
        updatedAt = selectionBox.updatedAt
        deletedAt = selectionBox.deletedAt
    }
}
