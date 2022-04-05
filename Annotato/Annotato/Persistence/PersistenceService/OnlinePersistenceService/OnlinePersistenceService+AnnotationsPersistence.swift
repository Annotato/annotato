import AnnotatoSharedLibrary
import Foundation

extension OnlinePersistenceService: AnnotationsPersistence {
    func createAnnotation(annotation: Annotation) async -> Annotation? {
        await remotePersistence.annotations.createAnnotation(annotation: annotation)
    }

    func updateAnnotation(annotation: Annotation) async -> Annotation? {
        await remotePersistence.annotations.updateAnnotation(annotation: annotation)
    }

    func deleteAnnotation(annotation: Annotation) async -> Annotation? {
        await remotePersistence.annotations.deleteAnnotation(annotation: annotation)
    }

    func createOrUpdateAnnotationsForLocal(annotations: [Annotation]) -> [Annotation]? {
        guard let localAnnotationsPersistence = localPersistence.annotations as? LocalAnnotationsPersistence else {
            AnnotatoLogger.error("Cannot cast local annotations persistence",
                                 context: "OnlinePersistenceService::createOrUpdateAnnotationForLocal")
            return nil
        }
        return localAnnotationsPersistence.createOrUpdateAnnotationsForLocal(annotations: annotations)
    }
}
