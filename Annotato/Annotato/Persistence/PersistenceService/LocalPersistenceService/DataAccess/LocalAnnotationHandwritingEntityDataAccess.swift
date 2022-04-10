import Foundation
import AnnotatoSharedLibrary

struct LocalAnnotationHandwritingEntityDataAccess {
    let context = LocalPersistenceService.sharedContext

    func read(annotationHandwritingEntityId: UUID) -> AnnotationHandwritingEntity? {
        context.performAndWait {
            context.rollback()

            let request = AnnotationHandwritingEntity.fetchRequest()

            do {
                let annotationHandwritingEntities = try context.fetch(request)
                    .filter { $0.id == annotationHandwritingEntityId }

                return annotationHandwritingEntities.first
            } catch {
                AnnotatoLogger.error("When reading annotation handwriting entity. \(String(describing: error))",
                                     context: "LocalAnnotationHandwritingEntityDataAccess::read")
                return nil
            }
        }
    }

    func readInCurrentContext(annotationHandwritingEntityId: UUID) -> AnnotationHandwritingEntity? {
        let request = AnnotationHandwritingEntity.fetchRequest()

        do {
            let annotationHandwritingEntities = try context.fetch(request)
                .filter { $0.id == annotationHandwritingEntityId }

            return annotationHandwritingEntities.first
        } catch {
            AnnotatoLogger.error("When reading annotation handwriting entity. \(String(describing: error))",
                                 context: "LocalAnnotationHandwritingEntityDataAccess::read")
            return nil
        }
    }
}
