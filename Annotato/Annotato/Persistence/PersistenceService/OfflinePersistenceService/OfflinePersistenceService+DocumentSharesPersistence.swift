import AnnotatoSharedLibrary
import Foundation

extension OfflinePersistenceService: DocumentSharesPersistence {
    func createDocumentShare(documentShare: DocumentShare) async -> DocumentShare? {
        await localPersistence.documentShares.createDocumentShare(documentShare: documentShare)
    }
}
