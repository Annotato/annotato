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
}
