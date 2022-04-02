import AnnotatoSharedLibrary
import Foundation

extension OnlinePersistenceService: DocumentSharesPersistence {
    func createDocumentShare(documentShare: DocumentShare) async -> DocumentShare? {
        guard let createdDocumentShareRemote = await remotePersistence
            .documentShares
            .createDocumentShare(documentShare: documentShare) else {
            return nil
        }
        return createdDocumentShareRemote
    }
}
