import AnnotatoSharedLibrary

extension AnnotationEntity {
    func customUpdate(usingUpdatedModel annotation: Annotation) {
        self.copyPropertiesOf(updatedModel: annotation)

        let annotationTexts = annotation.parts.compactMap({ $0 as? AnnotationText })
        for annotationText in annotationTexts {
            if let annotationTextEntity = LocalAnnotationTextEntityDataAccess
                .read(annotationTextEntityId: annotationText.id) {
                annotationTextEntity.customUpdate(usingUpdatedModel: annotationText)
            } else {
                addToAnnotationTextEntities(AnnotationTextEntity.fromModel(annotationText))
            }
        }

        let annotationHandwritings = annotation.parts.compactMap({ $0 as? AnnotationHandwriting })
        for annotationHandwriting in annotationHandwritings {
            if let annotationHandwritingEntity = LocalAnnotationHandwritingEntityDataAccess
                .read(annotationHandwritingEntityId: annotationHandwriting.id) {
                annotationHandwritingEntity.customUpdate(usingUpdatedModel: annotationHandwriting)
            } else {
                addToAnnotationHandwritingEntities(AnnotationHandwritingEntity.fromModel(annotationHandwriting))
            }
        }

        let selectionBox = annotation.selectionBox
        if let selectionBoxEntity = LocalSelectionBoxEntityDataAccess.read(selectionBoxId: selectionBox.id) {
            selectionBoxEntity.customUpdate(usingUpdatedModel: selectionBox)
        } else {
            _ = SelectionBoxEntity.fromModel(selectionBox)
        }
    }

    private func copyPropertiesOf(updatedModel annotation: Annotation) {
        precondition(id == annotation.id)

        originX = annotation.origin.x
        originY = annotation.origin.y
        width = annotation.width
        ownerId = annotation.ownerId

        if let documentEntity = LocalDocumentEntityDataAccess
            .read(documentId: annotation.documentId, withDeleted: true) {
            self.documentEntity = documentEntity
        }

        createdAt = annotation.createdAt
        updatedAt = annotation.updatedAt
        deletedAt = annotation.deletedAt
    }
}
