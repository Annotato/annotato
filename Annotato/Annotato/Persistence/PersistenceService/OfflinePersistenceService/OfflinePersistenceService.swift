import AnnotatoSharedLibrary
import Foundation

struct OfflinePersistenceService: PersistenceService {
    let localPersistence: PersistenceManager

    init(localPersistence: PersistenceManager) {
        self.localPersistence = localPersistence
    }

    func fastForwardLocalDocuments(documents: [Document]) async {
        AnnotatoLogger.error("This function should not be called",
                             context: "OfflinePersistenceService::fastForwardLocalDocuments")
        return
    }

    func fastForwardLocalAnnotations(annotations: [Annotation]) async {
        AnnotatoLogger.error("This function should not be called",
                             context: "OfflinePersistenceService::fastForwardLocalAnnotations")
        return
    }
}
