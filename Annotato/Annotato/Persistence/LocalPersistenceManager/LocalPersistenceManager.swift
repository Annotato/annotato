import Foundation
import CoreData

struct LocalPersistenceManager {
    static let shared = LocalPersistenceManager()
    private static let containerName = "AnnotatoLocal"

    private let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: LocalPersistenceManager.containerName)
        container.loadPersistentStores { _, error in
            if let error = error {
                let errorMessage = "Error loading Core Data: \(error)"
                AnnotatoLogger.error(errorMessage,
                                     context: "LocalPersistenceManager::init")
                fatalError(errorMessage)
            }
        }
    }

    func makeCoreDataEntity<T: Persistable>(class: T.Type) -> T.ManagedEntity {
        T.ManagedEntity(context: container.viewContext)
    }
}

extension LocalPersistenceManager: PersistenceManager {
    var documents: DocumentsPersistence {
        LocalDocumentsPersistence()
    }

    var documentShares: DocumentSharesPersistence {
        LocalDocumentSharesPersistence()
    }
}
