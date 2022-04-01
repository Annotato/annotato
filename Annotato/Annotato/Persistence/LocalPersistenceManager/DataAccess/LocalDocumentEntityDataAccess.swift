import Foundation
import AnnotatoSharedLibrary

struct LocalDocumentEntityDataAccess {
    static let context = LocalPersistenceManager.sharedContext

    static func read(documentId: UUID) -> DocumentEntity? {
        let request = DocumentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", documentId.uuidString)

        do {
            let documentEntities = try context.fetch(request)

            return documentEntities.first
        } catch {
            AnnotatoLogger.error("When reading document entity.",
                                 context: "LocalDocumentEntityDataAccess::read")
            return nil
        }
    }
}
