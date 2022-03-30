import Foundation
import CoreData

struct LocalPersistenceManager {
    static let sharedInstance = LocalPersistenceManager()
    private static let containerName = "AnnotatoLocal"

    private let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: LocalPersistenceManager.containerName)
        container.loadPersistentStores { _, error in
            if let error = error {
                AnnotatoLogger.error("Error loading Core Data: \(error)",
                                     context: "LocalPersistenceManager::init")
            }
        }
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
