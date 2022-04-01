import Foundation
import AnnotatoSharedLibrary

struct AnnotatoPersistence {
    static var currentPersistenceManager: PersistenceManager {
        if WebSocketManager.shared.isConnected {
            onlinePersistenceManager
        } else {
            offlinePersistenceManager
        }
    }
    static let remotePersistence: PersistenceManager = RemotePersistenceManager()
    static let localPersistence: PersistenceManager = LocalPersistenceManager.shared

    static let onlinePersistenceManager: PersistenceService = OnlinePersistenceManager(remotePersistence: remotePersistence, localPersistence: localPersistence)
    static let offlinePersistenceManager: PersistenceService = OfflinePersistenceManager(localPersistence: localPersistence)

    private init() { }
}
