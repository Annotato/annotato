import AnnotatoSharedLibrary
import Foundation

extension OnlinePersistenceService: AnnotationsPersistence {
    func createAnnotation(annotation: Annotation) async -> Annotation? {
        guard let createdAnnotationRemote = await remotePersistence
            .annotations
            .createAnnotation(annotation: annotation) else {
            return nil
        }
        guard let createdAnnotationLocal = await localPersistence
            .annotations
            .createAnnotation(annotation: createdAnnotationRemote) else {
            return nil
        }
        return createdAnnotationLocal
    }

    func updateAnnotation(annotation: Annotation) async -> Annotation? {
        guard let updatedAnnotationRemote = await remotePersistence
            .annotations
            .updateAnnotation(annotation: annotation) else {
            return nil
        }
        guard let updatedAnnotationLocal = await localPersistence
            .annotations
            .updateAnnotation(annotation: updatedAnnotationRemote) else {
            return nil
        }
        return updatedAnnotationLocal
    }

    func deleteAnnotation(annotation: Annotation) async -> Annotation? {
        guard let deletedAnnotationRemote = await remotePersistence
            .annotations
            .deleteAnnotation(annotation: annotation) else {
            return nil
        }
        guard let deletedAnnotationLocal = await localPersistence
            .annotations
            .deleteAnnotation(annotation: deletedAnnotationRemote) else {
            return nil
        }
        return deletedAnnotationLocal
    }

    func createOrUpdateAnnotation(annotation: Annotation) -> Annotation? {
        fatalError("OnlinePersistenceService::createOrUpdateAnnotation: This function should not be called")
        return nil
    }

    func createOrUpdateAnnotations(annotations: [Annotation]) -> [Annotation]? {
        fatalError("OnlinePersistenceService::createOrUpdateAnnotations: This function should not be called")
        return nil
    }
}
