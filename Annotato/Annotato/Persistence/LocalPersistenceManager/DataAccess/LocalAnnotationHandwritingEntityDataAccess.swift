import Foundation
import AnnotatoSharedLibrary

struct LocalAnnotationHandwritingEntityDataAccess {
    static let context = LocalPersistenceManager.sharedContext

    static func read(annotationHandwritingEntityId: UUID) -> AnnotationHandwritingEntity? {
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
