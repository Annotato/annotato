import Foundation
import AnnotatoSharedLibrary

struct AnnotatoPersistenceWrapper {
    static var currentPersistenceService: PersistenceService {
        onlinePersistenceService
    }

    private static let remotePersistence: PersistenceManager = RemotePersistenceManager()
    private static let localPersistence: PersistenceManager = LocalPersistenceManager.shared

    private static let onlinePersistenceService: PersistenceService = OnlinePersistenceService(
        remotePersistence: remotePersistence,
        localPersistence: localPersistence
    )

    private init() { }
}
