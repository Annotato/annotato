import AnnotatoSharedLibrary

extension AnnotationText: Persistable {
    static func fromManagedEntity(_ managedEntity: AnnotationTextEntity) -> Self {
        Self(
            type: TextType(rawValue: managedEntity.type.rawValue) ?? .plainText,
            content: managedEntity.content,
            height: managedEntity.height,
            order: Int(managedEntity.order),
            annotationId: managedEntity.annotationId,
            id: managedEntity.id
        )
    }
}
