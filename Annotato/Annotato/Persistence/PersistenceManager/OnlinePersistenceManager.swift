import Foundation

struct OnlinePersistenceManager: PersistenceService {
    private let remotePersistence: PersistenceManager
    private let localPersistence: PersistenceManager

    init(remotePersistence: PersistenceManager, localPersistence: PersistenceManager) {
        self.remotePersistence = remotePersistence
        self.localPersistence = localPersistence
    }
}
