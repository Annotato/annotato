import Foundation
import AnnotatoSharedLibrary

struct LocalAnnotationsPersistence: AnnotationsPersistence {
    func createAnnotation(annotation: Annotation) -> Annotation? {
        print("creating annotation")
        guard let newAnnotationEntity = LocalAnnotationEntityDataAccess.create(annotation: annotation) else {
            AnnotatoLogger.error("When creating annotation.",
                                 context: "LocalAnnotationsPersistence::createAnnotation")
            return nil
        }
        print("successfully created")
        return Annotation.fromManagedEntity(newAnnotationEntity)
    }

    func updateAnnotation(annotation: Annotation) -> Annotation? {
        print("updating annotation")
        guard let updatedAnnotationEntity = LocalAnnotationEntityDataAccess
            .update(annotationId: annotation.id, annotation: annotation) else {
            AnnotatoLogger.error("When updating annotation.",
                                 context: "LocalAnnotationsPersistence::updateAnnotation")
            return nil
        }
        print("successfully updated")
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

    func createOrUpdateAnnotationForLocal(annotation: Annotation) -> Annotation? {
        print("In local annotations persistence, creating or updating this annotation")
        if LocalAnnotationEntityDataAccess.read(annotationId: annotation.id,
                                                withDeleted: true) != nil {
            print("annotation exists")
            return updateAnnotation(annotation: annotation)
        } else {
            print("annotation doesn't exist")
            return createAnnotation(annotation: annotation)
        }
    }
}
