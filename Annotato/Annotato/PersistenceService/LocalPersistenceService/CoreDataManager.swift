import Foundation
import CoreData
import AnnotatoSharedLibrary

struct CoreDataManager {
    static var coreDataContext: NSManagedObjectContext {
        CoreDataManager.shared.container.viewContext
    }

    static func makeCoreDataEntity<T: Persistable>(class: T.Type) -> T.ManagedEntity {
        T.ManagedEntity(context: coreDataContext)
    }

    static let shared = CoreDataManager()

    private static let containerName = "AnnotatoLocal"

    private let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: CoreDataManager.containerName)
        container.loadPersistentStores { _, error in
            if let error = error {
                let errorMessage = "Error loading Core Data: \(error)"
                AnnotatoLogger.error(errorMessage,
                                     context: "LocalPersistenceService::init")
                fatalError(errorMessage)
            }
        }

        AnnotatoLogger.info("Core data container attached. \(container.persistentStoreDescriptions)",
                            context: "CoreDataManager::init")
    }
}
