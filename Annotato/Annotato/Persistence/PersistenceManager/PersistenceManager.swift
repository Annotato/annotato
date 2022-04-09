import AnnotatoSharedLibrary
import Foundation

struct PersistenceManager {
    let httpService: AnnotatoHTTPService

    let remotePersistence: PersistenceService
    let localPersistence: PersistenceService

    init(remotePersistence: PersistenceService, localPersistence: PersistenceService) {
        self.httpService = URLSessionHTTPService()
        self.remotePersistence = remotePersistence
        self.localPersistence = localPersistence
    }
}
