import Foundation
import AnnotatoSharedLibrary

struct LocalAnnotationEntityDataAccess {
    static let context = LocalPersistenceManager.sharedContext

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
}
