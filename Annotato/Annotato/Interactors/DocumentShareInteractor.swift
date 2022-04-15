import Foundation
import AnnotatoSharedLibrary

class DocumentShareInteractor {
    private let documentSharesPersistenceManager = DocumentSharesPersistenceManager()

    func createDocumentShare(documentId: UUID) async -> Document? {
        guard let currentUser = AuthViewModel().currentUser else {
            return nil
        }

        let documentShare = DocumentShare(documentId: documentId, recipientId: currentUser.id)

        return await documentSharesPersistenceManager.createDocumentShare(documentShare: documentShare)
    }
}