import Foundation
import AnnotatoSharedLibrary

struct LocalAnnotationHandwritingEntityDataAccess {
    static let context = LocalPersistenceManager.sharedContext

    static func read(annotationHandwritingEntityId: UUID) -> AnnotationHandwritingEntity? {
        let request = AnnotationHandwritingEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", annotationHandwritingEntityId.uuidString)

        do {
            let annotationHandwritingEntities = try context.fetch(request)

            return annotationHandwritingEntities.first
        } catch {
            AnnotatoLogger.error("When reading annotation handwriting entity.",
                                 context: "LocalAnnotationHandwritingEntityDataAccess::read")
            return nil
        }
    }
}
