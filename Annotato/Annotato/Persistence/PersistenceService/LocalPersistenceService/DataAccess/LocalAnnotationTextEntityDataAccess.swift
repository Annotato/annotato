import Foundation
import AnnotatoSharedLibrary

struct LocalAnnotationTextEntityDataAccess {
    static let context = LocalPersistenceService.sharedContext

    static func read(annotationTextEntityId: UUID) -> AnnotationTextEntity? {
        context.performAndWait {
            context.rollback()

            let request = AnnotationTextEntity.fetchRequest()

            do {
                let annotationTextEntities = try context.fetch(request).filter { $0.id == annotationTextEntityId }

                return annotationTextEntities.first
            } catch {
                AnnotatoLogger.error("When reading annotation text entity. \(String(describing: error))",
                                     context: "LocalAnnotationTextEntityDataAccess::read")
                return nil
            }
        }
    }

    static func readInCurrentContext(annotationTextEntityId: UUID) -> AnnotationTextEntity? {
        let request = AnnotationTextEntity.fetchRequest()

        do {
            let annotationTextEntities = try context.fetch(request).filter { $0.id == annotationTextEntityId }

            return annotationTextEntities.first
        } catch {
            AnnotatoLogger.error("When reading annotation text entity. \(String(describing: error))",
                                 context: "LocalAnnotationTextEntityDataAccess::readInCurrentContext")
            return nil
        }
    }
}