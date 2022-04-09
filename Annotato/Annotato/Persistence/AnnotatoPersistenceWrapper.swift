import Foundation
import AnnotatoSharedLibrary

struct AnnotatoPersistenceWrapper {
    static var currentPersistenceManager: PersistenceManager {
        persistenceManager
    }

    private static let remotePersistence: PersistenceService = RemotePersistenceService()
    private static let localPersistence: PersistenceService = LocalPersistenceService.shared

    private static let persistenceManager = PersistenceManager(
        remotePersistence: remotePersistence,
        localPersistence: localPersistence
    )

    private init() { }
}
