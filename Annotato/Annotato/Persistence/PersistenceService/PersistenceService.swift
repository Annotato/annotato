import AnnotatoSharedLibrary
import Foundation

struct PersistenceService {
    let httpService: AnnotatoHTTPService

    let remotePersistence: PersistenceManager
    let localPersistence: PersistenceManager

    init(remotePersistence: PersistenceManager, localPersistence: PersistenceManager) {
        self.httpService = URLSessionHTTPService()
        self.remotePersistence = remotePersistence
        self.localPersistence = localPersistence
    }
}
