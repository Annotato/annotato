import Foundation
import AnnotatoSharedLibrary

class DocumentSharePresenter {
    private let documentSharesPersistenceManager = DocumentSharesPersistenceManager()

    func createDocumentShare(documentId: UUID) async -> Bool {
        guard let currentUser = AuthPresenter().currentUser else {
            return false
        }

        let documentShare = DocumentShare(documentId: documentId, recipientId: currentUser.id)

        return await documentSharesPersistenceManager.createDocumentShare(documentShare: documentShare) != nil
    }
}
