import AnnotatoSharedLibrary
import Foundation

extension OfflinePersistenceService: DocumentSharesPersistence {
    func createDocumentShare(documentShare: DocumentShare) async -> Document? {
        await localPersistence.documentShares.createDocumentShare(documentShare: documentShare)
    }
}
