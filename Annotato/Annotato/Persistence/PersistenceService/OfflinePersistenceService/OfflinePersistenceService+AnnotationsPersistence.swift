import AnnotatoSharedLibrary
import Foundation

extension OfflinePersistenceService: AnnotationsPersistence {
    func createAnnotation(annotation: Annotation) async -> Annotation? {
        annotation.setCreatedAt(to: Date())
        return await localPersistence.annotations.createAnnotation(annotation: annotation)
    }

    func updateAnnotation(annotation: Annotation) async -> Annotation? {
        annotation.setUpdatedAt(to: Date())
        return await localPersistence.annotations.updateAnnotation(annotation: annotation)
    }

    func deleteAnnotation(annotation: Annotation) async -> Annotation? {
        annotation.setDeletedAt(to: Date())
        return await localPersistence.annotations.deleteAnnotation(annotation: annotation)
    }

    func createOrUpdateAnnotation(annotation: Annotation) async -> Annotation? {
        if LocalAnnotationEntityDataAccess.read(annotationId: annotation.id,
                                                withDeleted: true) != nil {
            return await self.updateAnnotation(annotation: annotation)
        } else {
            return await self.createAnnotation(annotation: annotation)
        }
    }

    func createOrUpdateAnnotations(annotations: [Annotation]) async -> [Annotation]? {
        var annotations: [Annotation] = []
        for annotation in annotations {
            guard let annotationToAppend = await self.createOrUpdateAnnotation(annotation: annotation) else {
                return nil
            }
            annotations.append(annotationToAppend)
        }
        return annotations
    }
}
