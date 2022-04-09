import AnnotatoSharedLibrary
import Foundation

extension PersistenceManager: AnnotationsPersistence {
    func createAnnotation(annotation: Annotation) async -> Annotation? {
        _ = await remotePersistence.annotations.createAnnotation(annotation: annotation)

        annotation.setCreatedAt()
        return await localPersistence.annotations.createAnnotation(annotation: annotation)
    }

    func updateAnnotation(annotation: Annotation) async -> Annotation? {
        _ = await remotePersistence.annotations.updateAnnotation(annotation: annotation)

        annotation.setUpdatedAt()
        return await localPersistence.annotations.updateAnnotation(annotation: annotation)
    }

    func deleteAnnotation(annotation: Annotation) async -> Annotation? {
        _ = await remotePersistence.annotations.deleteAnnotation(annotation: annotation)

        annotation.setDeletedAt()
        return await localPersistence.annotations.deleteAnnotation(annotation: annotation)
    }

    func createOrUpdateAnnotation(annotation: Annotation) -> Annotation? {
        fatalError("PersistenceManager::createOrUpdateAnnotation: This function should not be called")
        return nil
    }

    func createOrUpdateAnnotations(annotations: [Annotation]) -> [Annotation]? {
        fatalError("PersistenceManager::createOrUpdateAnnotations: This function should not be called")
        return nil
    }
}
