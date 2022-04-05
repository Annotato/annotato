import AnnotatoSharedLibrary
import Foundation

struct OnlinePersistenceService: PersistenceService {
    let remotePersistence: PersistenceManager
    let localPersistence: PersistenceManager

    init(remotePersistence: PersistenceManager, localPersistence: PersistenceManager) {
        self.remotePersistence = remotePersistence
        self.localPersistence = localPersistence
    }

    func fastForwardLocalDocuments(documents: [Document]) async {
        for document in documents {
            guard let _ = await self.createOrUpdateDocumentForLocal(document: document) else {
                AnnotatoLogger.error("Error when syncing this document to local: \(document)")
                continue
            }
        }
    }

    func fastForwardLocalAnnotations(annotations: [Annotation]) async {
        for annotation in annotations {
            guard let _ = await self.createOrUpdateAnnotationForLocal(annotation: annotation) else {
                AnnotatoLogger.error("Error when syncing this annotation to local: \(annotation)")
                continue
            }
        }
    }
}
