import Foundation
import AnnotatoSharedLibrary

struct LocalSelectionBoxEntityDataAccess {
    static let context = LocalPersistenceManager.sharedContext

    static func read(selectionBoxId: UUID) -> SelectionBoxEntity? {
        let request = SelectionBoxEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", selectionBoxId.uuidString)

        do {
            let selectionBoxEntities = try context.fetch(request)

            return selectionBoxEntities.first
        } catch {
            AnnotatoLogger.error("When reading selection box entity.",
                                 context: "LocalSelectionBoxEntityDataAccess::read")
            return nil
        }
    }
}
