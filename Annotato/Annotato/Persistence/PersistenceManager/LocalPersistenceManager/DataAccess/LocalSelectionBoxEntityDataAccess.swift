import Foundation
import AnnotatoSharedLibrary

struct LocalSelectionBoxEntityDataAccess {
    static let context = LocalPersistenceManager.sharedContext

    static func read(selectionBoxId: UUID) -> SelectionBoxEntity? {
        context.performAndWait {
            context.rollback()

            let request = SelectionBoxEntity.fetchRequest()

            do {
                let selectionBoxEntities = try context.fetch(request).filter { $0.id == selectionBoxId }

                return selectionBoxEntities.first
            } catch {
                AnnotatoLogger.error("When reading selection box entity. \(String(describing: error))",
                                     context: "LocalSelectionBoxEntityDataAccess::read")
                return nil
            }
        }
    }

    static func readInCurrentContext(selectionBoxId: UUID) -> SelectionBoxEntity? {
        let request = SelectionBoxEntity.fetchRequest()

        do {
            let selectionBoxEntities = try context.fetch(request).filter { $0.id == selectionBoxId }

            return selectionBoxEntities.first
        } catch {
            AnnotatoLogger.error("When reading selection box entity. \(String(describing: error))",
                                 context: "LocalSelectionBoxEntityDataAccess::read")
            return nil
        }
    }
}
