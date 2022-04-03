import Foundation
import AnnotatoSharedLibrary

struct LocalAnnotationEntityDataAccess {
    static let context = LocalPersistenceManager.sharedContext

    static func create(annotation: Annotation) -> AnnotationEntity? {
        context.rollback()
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

    static func read(annotationId: UUID, withDeleted: Bool) -> AnnotationEntity? {
        let request = AnnotationEntity.fetchRequest()

        do {
            var annotationEntities = try context.fetch(request).filter { $0.id == annotationId }
            if !withDeleted {
                annotationEntities = AnnotationEntity.removeDeletedAnnotationEntities(annotationEntities)
            }

            return annotationEntities.first
        } catch {
            AnnotatoLogger.error("When reading annotation entity. \(String(describing: error))",
                                 context: "LocalAnnotationDataAccess::read")
            return nil
        }
    }

    static func update(annotationId: UUID, annotation: Annotation) -> AnnotationEntity? {
        context.rollback()
        guard let annotationEntity = LocalAnnotationEntityDataAccess.read(annotationId: annotationId,
                                                                          withDeleted: true) else {
            AnnotatoLogger.error("When finding existing annotation entity.",
                                 context: "LocalAnnotationEntityDataAccess::update")
            return nil
        }

        annotationEntity.customUpdate(usingUpdatedModel: annotation)

        do {
            try context.save()
        } catch {
            AnnotatoLogger.error("When updating annotation entity. \(String(describing: error))",
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