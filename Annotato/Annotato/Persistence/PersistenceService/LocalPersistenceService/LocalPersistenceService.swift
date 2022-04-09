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

extension LocalPersistenceService: PersistenceService {
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

extension LocalPersistenceService {
    func fetchDocumentsCreatedAfterDate(date: Date) -> [Document]? {
        let documentEntities = LocalDocumentEntityDataAccess.listCreatedAfterDate(date: date)

        guard let documentEntities = documentEntities else {
            AnnotatoLogger.error("When getting created documents after date",
                                 context: "LocalPersistenceService::fetchDocumentsCreatedAfterDate")
            return nil
        }

        return documentEntities.map(Document.fromManagedEntity)
    }

    func fetchDocumentsUpdatedAfterDate(date: Date) -> [Document]? {
        let documentEntities = LocalDocumentEntityDataAccess.listUpdatedAfterDate(date: date)

        guard let documentEntities = documentEntities else {
            AnnotatoLogger.error("When getting updated documents after date",
                                 context: "LocalPersistenceService::fetchDocumentsUpdatedAfterDate")
            return nil
        }

        return documentEntities.map(Document.fromManagedEntity)
    }

    func fetchAnnotationsCreatedAfterDate(date: Date) -> [Annotation]? {
        let annotationEntities = LocalAnnotationEntityDataAccess.listCreatedAfterDate(date: date)

        guard let annotationEntities = annotationEntities else {
            AnnotatoLogger.error("When getting created annotations after date",
                                 context: "LocalPersistenceService::fetchAnnotationsCreatedAfterDate")
            return nil
        }

        return annotationEntities.map(Annotation.fromManagedEntity)
    }

    func fetchAnnotationsUpdatedAfterDate(date: Date) -> [Annotation]? {
        let annotationEntities = LocalAnnotationEntityDataAccess.listUpdatedAfterDate(date: date)

        guard let annotationEntities = annotationEntities else {
            AnnotatoLogger.error("When getting updated annotations after date",
                                 context: "LocalPersistenceService::fetchAnnotationsUpdatedAfterDate")
            return nil
        }

        return annotationEntities.map(Annotation.fromManagedEntity)
    }
}
