import Foundation
import AnnotatoSharedLibrary

struct AnnotatoPersistenceWrapper {
    static var currentPersistenceService: PersistenceService {
        persistenceService
    }

    private static let remotePersistence: PersistenceManager = RemotePersistenceManager()
    private static let localPersistence: PersistenceManager = LocalPersistenceManager.shared

    private static let persistenceService = PersistenceService(
        remotePersistence: remotePersistence,
        localPersistence: localPersistence
    )

    private init() { }
}
