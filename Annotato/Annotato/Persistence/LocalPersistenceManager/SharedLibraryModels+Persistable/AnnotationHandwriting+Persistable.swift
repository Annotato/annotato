import AnnotatoSharedLibrary

extension AnnotationHandwriting: Persistable {
    static func fromManagedEntity(_ managedEntity: AnnotationHandwritingEntity) -> Self {
        Self(
            order: Int(managedEntity.order),
            height: managedEntity.height,
            annotationId: managedEntity.annotationId,
            handwriting: managedEntity.handwriting,
            id: managedEntity.id
        )
    }
}
