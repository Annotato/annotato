import Foundation
import AnnotatoSharedLibrary

struct AnnotatoPersistence {
    static var currentPersistenceService: PersistenceService {
        WebSocketManager.shared.isConnected ? onlinePersistenceManager : offlinePersistenceManager
    }

    static let remotePersistence: PersistenceManager = RemotePersistenceManager()
    static let localPersistence: PersistenceManager = LocalPersistenceManager.shared

    static let onlinePersistenceManager: PersistenceService = OnlinePersistenceService(
        remotePersistence: remotePersistence,
        localPersistence: localPersistence
    )
    static let offlinePersistenceManager: PersistenceService = OfflinePersistenceService(
        localPersistence: localPersistence
    )

    private init() { }
}
