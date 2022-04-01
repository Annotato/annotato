import Foundation
import AnnotatoSharedLibrary

struct LocalAnnotationsPersistence: AnnotationsPersistence {
    func createAnnotation(annotation: Annotation) async -> Annotation? {
        guard let newAnnotationEntity = LocalAnnotationEntityDataAccess.create(annotation: annotation) else {
            AnnotatoLogger.error("When creating annotation.",
                                 context: "LocalAnnotationsPersistence::createAnnotation")
            return nil
        }

        return Annotation.fromManagedEntity(newAnnotationEntity)
    }

    func updateAnnotation(annotation: Annotation) async -> Annotation? {
        guard let updatedAnnotationEntity = LocalAnnotationEntityDataAccess
            .update(annotationId: annotation.id, annotation: annotation) else {
            AnnotatoLogger.error("When updating annotation.",
                                 context: "LocalAnnotationsPersistence::updateAnnotation")
            return nil
        }

        return Annotation.fromManagedEntity(updatedAnnotationEntity)
    }

    func deleteAnnotation(annotation: Annotation) async -> Annotation? {
        guard let deletedAnnotation = LocalAnnotationEntityDataAccess
            .delete(annotationId: annotation.id, annotation: annotation) else {
            AnnotatoLogger.error("When deleting annotation.",
                                 context: "LocalAnnotationsPersistence::deleteAnnotation")
            return nil
        }

        return Annotation.fromManagedEntity(deletedAnnotation)
    }
}
