import Foundation
import CoreData
import AnnotatoSharedLibrary

struct LocalPersistenceManager {
    static var sharedContext: NSManagedObjectContext {
        LocalPersistenceManager.shared.container.viewContext
    }

    static func makeCoreDataEntity<T: Persistable>(class: T.Type) -> T.ManagedEntity {
        T.ManagedEntity(context: sharedContext)
    }

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

        AnnotatoLogger.info("Core data container attached. \(container.persistentStoreDescriptions)",
                            context: "LocalPersistenceManager::init")
    }
}

extension LocalPersistenceManager: PersistenceManager {
    var documents: DocumentsPersistence {
        LocalDocumentsPersistence()
    }

    var documentShares: DocumentSharesPersistence {
        LocalDocumentSharesPersistence()
    }

    var annotations: AnnotationsPersistence {
        LocalAnnotationsPersistence()
    }
}

extension LocalPersistenceManager {
    func fetchDocumentsUpdatedAfterDate(date: Date) -> [Document]? {
        let documentEntities = LocalDocumentEntityDataAccess.listUpdatedAfterDate(date: date)

        guard let documentEntities = documentEntities else {
            AnnotatoLogger.error("When getting updated documents after date",
                                 context: "LocalPersistenceManager::fetchDocumentsUpdatedAfterDate")
            return nil
        }

        return documentEntities.map(Document.fromManagedEntity)
    }

    func fetchAnnoationsUpdatedAfterDate(date: Date) -> [Annotation]? {
        let annotationEntities = LocalAnnotationEntityDataAccess.listUpdatedAfterDate(date: date)

        guard let annotationEntities = annotationEntities else {
            AnnotatoLogger.error("When getting updated annotations after date",
                                 context: "LocalPersistenceManager::fetchAnnoationsUpdatedAfterDate")
            return nil
        }

        return annotationEntities.map(Annotation.fromManagedEntity)
    }
}
