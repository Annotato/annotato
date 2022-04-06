import AnnotatoSharedLibrary
import Foundation

extension OnlinePersistenceService: AnnotationsPersistence {
    func createAnnotation(annotation: Annotation) async -> Annotation? {
       _ = await remotePersistence
            .annotations
            .createAnnotation(annotation: annotation)

        // Local persistence is done by the websocket manager on receiving a response
        return nil
    }

    func updateAnnotation(annotation: Annotation) async -> Annotation? {
        _ = await remotePersistence
            .annotations
            .updateAnnotation(annotation: annotation)

        // Local persistence is done by the websocket manager on receiving a response
        return nil
    }

    func deleteAnnotation(annotation: Annotation) async -> Annotation? {
        _ = await remotePersistence
            .annotations
            .deleteAnnotation(annotation: annotation)

        // Local persistence is done by the websocket manager on receiving a response
        return nil
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
