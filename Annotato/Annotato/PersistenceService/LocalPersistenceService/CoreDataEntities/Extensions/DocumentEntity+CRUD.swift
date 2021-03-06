import AnnotatoSharedLibrary

extension DocumentEntity {
    func customUpdate(usingUpdatedModel document: Document) {
        self.copyPropertiesOf(updatedModel: document)

        for annotation in document.annotations {
            if let annotationEntity = LocalAnnotationEntityDataAccess()
                .readInCurrentContext(annotationId: annotation.id,
                                      withDeleted: true) {
                annotationEntity.customUpdate(usingUpdatedModel: annotation)
            } else {
                addToAnnotationEntities(AnnotationEntity.fromModel(annotation))
            }
        }
    }

    func copyPropertiesOf(updatedModel document: Document) {
        precondition(id == document.id)

        name = document.name
        ownerId = document.ownerId

        createdAt = document.createdAt
        updatedAt = document.updatedAt
        deletedAt = document.deletedAt
    }
}
