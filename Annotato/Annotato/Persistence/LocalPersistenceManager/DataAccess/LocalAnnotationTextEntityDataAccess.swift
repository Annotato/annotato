import Foundation
import AnnotatoSharedLibrary

struct LocalAnnotationTextEntityDataAccess {
    static let context = LocalPersistenceManager.sharedContext

    static func read(annotationTextEntityId: UUID) -> AnnotationTextEntity? {
        let request = AnnotationTextEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", annotationTextEntityId.uuidString)

        do {
            let annotationTextEntities = try context.fetch(request)

            return annotationTextEntities.first
        } catch {
            AnnotatoLogger.error("When reading annotation text entity.",
                                 context: "LocalAnnotationTextEntityDataAccess::read")
            return nil
        }
    }
}
