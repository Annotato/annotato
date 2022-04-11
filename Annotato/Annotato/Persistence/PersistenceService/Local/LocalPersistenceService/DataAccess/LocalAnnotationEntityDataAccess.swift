import Foundation
import AnnotatoSharedLibrary

struct LocalAnnotationEntityDataAccess {
    let context = LocalPersistenceService.sharedContext

    func listCreatedAfterDate(date: Date) -> [AnnotationEntity]? {
        context.performAndWait {
            context.rollback()

            let request = AnnotationEntity.fetchRequest()

            do {
                let annotationEntities = try context.fetch(request).filter { $0.wasCreated(after: date) }

                return annotationEntities
            } catch {
                AnnotatoLogger.error("When fetching created document entities after date. \(String(describing: error))",
                                     context: "LocalDocumentEntityDataAccess::listCreatedAfterDate")
                return nil
            }
        }
    }

    func listUpdatedAfterDate(date: Date) -> [AnnotationEntity]? {
        context.performAndWait {
            context.rollback()

            let request = AnnotationEntity.fetchRequest()

            do {
                let annotationEntities = try context.fetch(request).filter { $0.wasUpdated(after: date) }

                return annotationEntities
            } catch {
                AnnotatoLogger.error("When fetching updated document entities after date. \(String(describing: error))",
                                     context: "LocalDocumentEntityDataAccess::listUpdatedAfterDate")
                return nil
            }
        }
    }

    func create(annotation: Annotation) -> AnnotationEntity? {
        context.performAndWait {
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
    }

    func read(annotationId: UUID, withDeleted: Bool) -> AnnotationEntity? {
        context.performAndWait {
            context.rollback()

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
    }

    func readInCurrentContext(annotationId: UUID, withDeleted: Bool) -> AnnotationEntity? {
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

    func update(annotationId: UUID, annotation: Annotation) -> AnnotationEntity? {
        context.performAndWait {
            context.rollback()

            guard let annotationEntity = readInCurrentContext(annotationId: annotationId,
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
    }

    func delete(annotationId: UUID, annotation: Annotation) -> AnnotationEntity? {
        // Deleting is the same as updating deletedAt
        return update(annotationId: annotationId, annotation: annotation)
    }
}
