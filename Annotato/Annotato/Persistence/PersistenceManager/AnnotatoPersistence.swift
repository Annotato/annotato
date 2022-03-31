import Foundation
import AnnotatoSharedLibrary

struct AnnotatoPersistence: PersistenceManager {
    static let shared = AnnotatoPersistence()
    static let remotePersistence: PersistenceManager = RemotePersistenceManager()
    static let localPersistence: PersistenceManager = LocalPersistenceManager.shared

    private init() { }
    var documents: DocumentsPersistence = AnnotatoDocumentsPersistence()
    var documentShares: DocumentSharesPersistence = AnnotatoDocumentSharesPersistence()
}
