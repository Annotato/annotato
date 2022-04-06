import Foundation
import AnnotatoSharedLibrary

struct LocalAnnotationsPersistence: AnnotationsPersistence {
    func createAnnotation(annotation: Annotation) -> Annotation? {
        guard let newAnnotationEntity = LocalAnnotationEntityDataAccess.create(annotation: annotation) else {
            AnnotatoLogger.error("When creating annotation.",
                                 context: "LocalAnnotationsPersistence::createAnnotation")
            return nil
        }
        return Annotation.fromManagedEntity(newAnnotationEntity)
    }

    func updateAnnotation(annotation: Annotation) -> Annotation? {
        guard let updatedAnnotationEntity = LocalAnnotationEntityDataAccess
            .update(annotationId: annotation.id, annotation: annotation) else {
            AnnotatoLogger.error("When updating annotation.",
                                 context: "LocalAnnotationsPersistence::updateAnnotation")
            return nil
        }
        return Annotation.fromManagedEntity(updatedAnnotationEntity)
    }

    func deleteAnnotation(annotation: Annotation) -> Annotation? {
        guard let deletedAnnotation = LocalAnnotationEntityDataAccess
            .delete(annotationId: annotation.id, annotation: annotation) else {
            AnnotatoLogger.error("When deleting annotation.",
                                 context: "LocalAnnotationsPersistence::deleteAnnotation")
            return nil
        }

        return Annotation.fromManagedEntity(deletedAnnotation)
    }

    func createOrUpdateAnnotation(annotation: Annotation) -> Annotation? {
        if LocalAnnotationEntityDataAccess.read(annotationId: annotation.id,
                                                withDeleted: true) != nil {
            return updateAnnotation(annotation: annotation)
        } else {
            return createAnnotation(annotation: annotation)
        }
    }

    func createOrUpdateAnnotations(annotations: [Annotation]) -> [Annotation]? {
        annotations.compactMap({ annotation in
            createOrUpdateAnnotation(annotation: annotation)
        })
    }
}
