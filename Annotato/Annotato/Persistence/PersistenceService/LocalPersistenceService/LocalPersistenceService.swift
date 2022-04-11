import Foundation
import CoreData
import AnnotatoSharedLibrary

struct LocalPersistenceService {
    static var sharedContext: NSManagedObjectContext {
        LocalPersistenceService.shared.container.viewContext
    }

    static func makeCoreDataEntity<T: Persistable>(class: T.Type) -> T.ManagedEntity {
        T.ManagedEntity(context: sharedContext)
    }

    static let shared = LocalPersistenceService()

    private static let containerName = "AnnotatoLocal"

    private let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: LocalPersistenceService.containerName)
        container.loadPersistentStores { _, error in
            if let error = error {
                let errorMessage = "Error loading Core Data: \(error)"
                AnnotatoLogger.error(errorMessage,
                                     context: "LocalPersistenceService::init")
                fatalError(errorMessage)
            }
        }

        AnnotatoLogger.info("Core data container attached. \(container.persistentStoreDescriptions)",
                            context: "LocalPersistenceService::init")
    }
}

extension LocalPersistenceService {
    var documents: DocumentsLocalPersistence {
        LocalDocumentsPersistence()
    }

    var documentShares: DocumentSharesRemotePersistence {
        LocalDocumentSharesPersistence()
    }

    var annotations: AnnotationsLocalPersistence {
        LocalAnnotationsPersistence()
    }

    var users: UsersPersistence {
        LocalUsersPersistence()
    }
}
