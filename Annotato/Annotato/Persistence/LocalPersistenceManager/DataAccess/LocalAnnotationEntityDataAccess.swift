import Foundation
import AnnotatoSharedLibrary

struct LocalAnnotationEntityDataAccess {
    static let context = LocalPersistenceManager.sharedContext

    static func create(annotation: Annotation) -> AnnotationEntity? {
        let annotationEntity = AnnotationEntity.fromModel(annotation)

        do {
            try context.save()
        } catch {
            AnnotatoLogger.error("When creating annotation: \(String(describing: error))",
                                 context: "LocalAnnotationEntityDataAccess::create")
            return nil
        }

        return annotationEntity
    }

    static func read(annotationId: UUID) -> AnnotationEntity? {
        let request = AnnotationEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", annotationId.uuidString)

        do {
            let annotationEntities = try context.fetch(request)

            return annotationEntities.first
        } catch {
            AnnotatoLogger.error("When reading annotation entity.",
                                 context: "LocalAnnotationDataAccess::read")
            return nil
        }
    }

    static func update(annotationId: UUID, annotation: Annotation) -> AnnotationEntity? {
        guard let annotationEntity = LocalAnnotationEntityDataAccess.read(annotationId: annotationId) else {
            AnnotatoLogger.error("When finding existing annotation entity.",
                                 context: "LocalAnnotationEntityDataAccess::update")
            return nil
        }

        annotationEntity.customUpdate(usingUpdatedModel: annotation)

        do {
            try context.save()
        } catch {
            AnnotatoLogger.error("When updating annotation entity.",
                                 context: "LocalAnnotationEntityDataAccess::update")
            return nil
        }

        return annotationEntity
    }

    static func delete(annotationId: UUID, annotation: Annotation) -> AnnotationEntity? {
        // Deleting is the same as updating deletedAt
        return update(annotationId: annotationId, annotation: annotation)
    }
}
