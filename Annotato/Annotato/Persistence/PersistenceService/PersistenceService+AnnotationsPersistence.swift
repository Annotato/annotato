import AnnotatoSharedLibrary
import Foundation

extension PersistenceService: AnnotationsPersistence {
    func createAnnotation(annotation: Annotation) async -> Annotation? {
        _ = await remotePersistence.annotations.createAnnotation(annotation: annotation)

        annotation.setCreatedAt(to: Date())
        return await localPersistence.annotations.createAnnotation(annotation: annotation)
    }

    func updateAnnotation(annotation: Annotation) async -> Annotation? {
        _ = await remotePersistence.annotations.updateAnnotation(annotation: annotation)

        annotation.setUpdatedAt(to: Date())
        return await localPersistence.annotations.updateAnnotation(annotation: annotation)
    }

    func deleteAnnotation(annotation: Annotation) async -> Annotation? {
        _ = await remotePersistence.annotations.deleteAnnotation(annotation: annotation)

        annotation.setDeletedAt(to: Date())
        return await localPersistence.annotations.deleteAnnotation(annotation: annotation)
    }

    func createOrUpdateAnnotation(annotation: Annotation) -> Annotation? {
        fatalError("PersistenceService::createOrUpdateAnnotation: This function should not be called")
        return nil
    }

    func createOrUpdateAnnotations(annotations: [Annotation]) -> [Annotation]? {
        fatalError("PersistenceService::createOrUpdateAnnotations: This function should not be called")
        return nil
    }
}
