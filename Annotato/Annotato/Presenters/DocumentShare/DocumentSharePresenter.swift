import Foundation
import AnnotatoSharedLibrary

class DocumentSharePresenter {
    private let documentSharesInteractor = DocumentSharesInteractor()

    func createDocumentShare(documentId: UUID) async -> Bool {
        guard let currentUser = AuthPresenter().currentUser else {
            return false
        }

        let documentShare = DocumentShare(documentId: documentId, recipientId: currentUser.id)

        return await documentSharesInteractor.createDocumentShare(documentShare: documentShare) != nil
    }
}
