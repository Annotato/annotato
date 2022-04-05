import AnnotatoSharedLibrary
import Foundation

struct OfflinePersistenceService: PersistenceService {
    let localPersistence: PersistenceManager

    init(localPersistence: PersistenceManager) {
        self.localPersistence = localPersistence
    }
}
