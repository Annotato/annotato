import AnnotatoSharedLibrary
import Foundation

struct OnlinePersistenceService: PersistenceService {
    let remotePersistence: PersistenceManager
    let localPersistence: PersistenceManager

    init(remotePersistence: PersistenceManager, localPersistence: PersistenceManager) {
        self.remotePersistence = remotePersistence
        self.localPersistence = localPersistence
    }

    func fastForwardLocalDocuments(documents: [Document]) {
        for document in documents {
            guard self.createOrUpdateDocumentForLocal(document: document) != nil else {
                AnnotatoLogger.error("Error when syncing this document to local: \(document)")
                continue
            }
        }
    }

    func fastForwardLocalAnnotations(annotations: [Annotation]) {
        for annotation in annotations {
            guard self.createOrUpdateAnnotationForLocal(annotation: annotation) != nil else {
                AnnotatoLogger.error("Error when syncing this annotation to local: \(annotation)")
                continue
            }
        }
    }
}
