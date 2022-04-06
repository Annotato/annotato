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

    func createOrUpdateAnnotation(annotation: Annotation) -> Annotation? {
        localPersistence.annotations.createOrUpdateAnnotation(annotation: annotation)
    }

    func createOrUpdateAnnotations(annotations: [Annotation]) -> [Annotation]? {
        localPersistence.annotations.createOrUpdateAnnotations(annotations: annotations)
    }
}
