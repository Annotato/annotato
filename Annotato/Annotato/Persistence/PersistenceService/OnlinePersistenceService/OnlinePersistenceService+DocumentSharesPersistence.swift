import AnnotatoSharedLibrary
import Foundation

extension OnlinePersistenceService: DocumentSharesPersistence {
    func createDocumentShare(documentShare: DocumentShare) async -> Document? {
        guard let sharedDocument = await remotePersistence
            .documentShares
            .createDocumentShare(documentShare: documentShare) else {
            return nil
        }

        _ = await localPersistence.documents.createDocument(document: sharedDocument)
        return sharedDocument
    }
}
