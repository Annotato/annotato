import AnnotatoSharedLibrary
import Foundation

extension OnlinePersistenceService: DocumentSharesPersistence {
    func createDocumentShare(documentShare: DocumentShare) async -> Document? {
        guard let sharedDocumentRemote = await remotePersistence
            .documentShares
            .createDocumentShare(documentShare: documentShare) else {
            return nil
        }

        let sharedDocumentLocal = await localPersistence.documents.createDocument(document: sharedDocumentRemote)
        return sharedDocumentLocal
    }
}
